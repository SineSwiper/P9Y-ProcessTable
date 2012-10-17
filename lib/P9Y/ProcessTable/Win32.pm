package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.92'; # VERSION

#############################################################################
# Modules

use sanity;
use Moo;
use P9Y::ProcessTable::Process;

use Win32::Process;
use Win32::Process::Info;

use namespace::clean;
no warnings 'uninitialized';

my $pi = Win32::Process::Info->new();

#############################################################################
# Methods

no warnings 'redefine';

sub list {
   my $self = shift;
   return sort { $a <=> $b } ($pi->ListPids);
}

sub fields {
   return ( qw/
      pid uid ppid sess
      exe root
      ttlflt utime stime start state time
      threads priority fname state size rss
   / );
}

sub process {
   my ($self, $pid) = @_;
   $pid = Win32::Process::GetCurrentProcessID if (@_ == 1);  # process() changed here...
   my $hash = $self->_process_hash($pid);
   return unless $hash && $hash->{pid} && $hash->{ppid};
   
   $hash->{_pt_obj} = $self;
   return P9Y::ProcessTable::Process->new($hash);
}

sub _process_hash {
   my ($self, $pid) = @_;
   my $info = $pi->GetProcInfo($pid);
   return unless $info;
   $info = $info->[0];

   my $hash = {};
   state $stat_loc = { qw/
      pid        ProcessId
      uid        Owner
      ppid       ParentProcessId
      sess       SessionId
      exe        ExecutablePath
      threads    ThreadCount
      priority   Priority
      ttlflt     PageFaults
      utime      UserModeTime
      stime      KernelModeTime
      size       VirtualSize
      rss        WorkingSetSize
      fname      Caption
      start      CreationDate
      state      Status
      cmdline    CommandLine
   / };

   foreach my $key (keys %$stat_loc) {
      my $item = $info->{ $stat_loc->{$key} };
      $hash->{$key} = $item if defined $item;
   }

   $hash->{exe}  =~ /^(\w\:\\)/;
   $hash->{root} = $1;
   $hash->{time} = $hash->{utime} + $hash->{stime};

   return $hash;
}

#############################################################################
# Process side

### FIXME: Can't get Win32::API to not crash on me... ###

package  # hide from PAUSE
   P9Y::ProcessTable::Process;

use Win32::Process;
#use Win32::API;
#use Win32::API::Callback;

BEGIN {
   #Win32::API->Import( 'user32', 'EnumWindows',              'KN', 'N' );
   #Win32::API->Import( 'user32', 'GetWindowThreadProcessId', 'NP', 'N' );
   #Win32::API->Import( 'user32', 'PostMessage',              'NINN', 'N' );
}

no warnings 'redefine';

sub _win32_proc {
   my $self = shift;
   my $obj;
   Win32::Process::Open($obj, $self->pid, 0);
   return $obj;
}

sub kill {
   my ($self, $sig) = @_;

   # Windows's signal.h actually has plenty of gaps, but it still follows Linux's model where
   # there isn't gaps.  Thus, we'll just fill in the blanks.

   # POSIX = 0 HUP INT QUIT ILL TRAP ABRT . FPE KILL . SEGV . PIPE ALRM TERM . . . . . . ABRT
   # 0x0010 = WM_CLOSE
   state $posix2wm = [
      0, 0x0010, 0x0010, qw/kill kill kill kill . kill kill . kill ./, 0x0010, 0x0010, 0x0010, qw/. . . . . . kill/
   ];

   $sig = $posix2wm->[$sig];
   return if (!$sig || $sig eq '.');
   if    ($sig eq '0') {
      return CORE::kill($sig, $self->pid);
   }
   elsif ($sig eq 'kill') {
      return $self->_win32_proc->Kill(255);
   }
   else {
      #my $cb = Win32::API::Callback->new( sub {
      #   my $hwnd = shift;
      #   my $pid = 0;
      #
      #   #GetWindowThreadProcessId($hwnd, \$pid);
      #   print "foo\n";
      #   #PostMessage($hwnd, $sig) if ($$pid && $$pid == $self->pid);
      #}, "NN", "N" );
      #
      #my $ret = EnumWindows($cb, 0);
      return $self->_win32_proc->Kill(255);
   }
}

sub priority {
   my ($self, $pri) = @_;
   return $self->{priority} if @_ == 1;
   
   $self->_win32_proc->SetPriorityClass($pri);
   $self->_set_priority($pri);
}

42;
