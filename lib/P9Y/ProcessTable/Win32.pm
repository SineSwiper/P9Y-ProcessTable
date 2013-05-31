package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.96'; # VERSION

#############################################################################
# Modules

# use sanity;
use strict qw(subs vars);
no strict 'refs';
use warnings FATAL => 'all';
no warnings qw(uninitialized);

use Moo;
use P9Y::ProcessTable::Process;

use Win32::Process;
use Win32::Process::Info;

use namespace::clean;
no warnings 'uninitialized';

my $pi = Win32::Process::Info->new();

my $IS_CYGWIN = ($^O =~ /cygwin/i) ? 1 : 0;

#############################################################################
# Methods

no warnings 'redefine';

sub list {
   my ($self) = @_;
   my %winpids = map { $_ => 1 } $self->_win32_list;
   my %cygpids = map { $_ => 1 } ($IS_CYGWIN ? $self->_cyg_list : ());
   my %pids = (%winpids, %cygpids);
   return sort { $a <=> $b } keys %pids;
}

sub fields {
   my ($self) = @_;
   my %winflds = map { $_ => 1 } $self->_win32_fields;
   my %cygflds = map { $_ => 1 } ($IS_CYGWIN ? $self->_cyg_fields : ());
   my %fields = (%winflds, %cygflds);

   # (keeps the order straight)
   return grep { $fields{$_} } ( qw/
      pid uid gid euid egid suid sgid ppid pgrp sess
      cwd exe root cmdline environ
      minflt cminflt majflt cmajflt ttlflt cttlflt utime stime cutime cstime start time ctime
      priority fname state ttynum ttydev flags threads size rss wchan cpuid pctcpu pctmem
      winpid winexe
   / );
}

sub process {
   my ($self, $pid) = @_;
   $pid = $$ unless defined $pid;
   my $hash = $self->_process_hash($pid);
   return unless $hash && $hash->{pid} && $hash->{ppid};

   $hash->{_pt_obj} = $self;
   return P9Y::ProcessTable::Process->new($hash);
}

sub _process_hash {
   my ($self, $pid) = @_;
   return ($IS_CYGWIN and Cygwin::pid_to_winpid($pid)) ?
      $self->  _cyg_process_hash($pid) :
      $self->_win32_process_hash($pid)
   ;
}

############################
## Win32 only methods

sub _win32_list {
   return sort { $a <=> $b } ($pi->ListPids);
}

sub _win32_fields {
   return qw(
      pid uid ppid sess
      exe root
      ttlflt utime stime start state time
      threads priority fname state size rss
   );
}

sub _win32_process_hash {
   my ($self, $pid) = @_;
   my $info = $pi->GetProcInfo($pid);
   return unless $info;
   $info = $info->[0];

   my $hash = {};
   my $stat_loc = { qw/
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

   $hash->{exe} =~ /^(\w\:\\)/;
   $hash->{root} = $1;
   $hash->{time} = $hash->{utime} + $hash->{stime};

   return $hash;
}

############################
## Cygwin only methods

### TODO: Leverage ProcFS, instead of copying the same code ###

sub _cyg_list {
   my @list;

   my $dir = dir('', 'proc');
   while (my $pdir = $dir->next) {
      next unless ($pdir->is_dir);
      next unless (-e $pdir->file('status'));
      next unless ($pdir->basename =~ /^\d+$/);

      push @list, $pdir->basename;
   }

   return @list;
}

sub _cyg_fields {
   return qw(
      pid uid gid ppid pgrp sess
      cwd exe root cmdline
      minflt cminflt majflt cmajflt ttlflt cttlflt
      utime stime cutime cstime start time ctime
      priority fname state ttynum flags size rss
      winpid winexe
   );
}

sub _cyg_process_hash {
   my ($self, $pid) = @_;

   my $pdir = dir('', 'proc', $pid);
   return unless (-d $pdir);
   my $hash = {
      pid   => $pid,
      uid   => $pdir->stat->uid,
      gid   => $pdir->stat->gid,
      start => $pdir->stat->mtime,
   };

   # process links
   foreach my $ln (qw{cwd exe root}) {
      my $link = $pdir->file($ln);
      $hash->{$ln} = readlink $link if (-l $link);
   }

   # process simple cats
   foreach my $fn (qw{cmdline winpid winexename}) {
      my $file = $pdir->file($fn);
      next unless (-f $file);
      $hash->{$fn} = $file->slurp;
      $hash->{$fn} =~ s/\0/ /g;
      $hash->{$fn} =~ s/^\s+|\s+$//g;
      $hash->{winexe} = delete $hash->{$fn} if ($fn eq 'winexename');
   }

   # process main PID stats
   if (-f $pdir->file('stat')) {

      # stat
      my $data = $pdir->file('stat')->slurp;
      my @data = split /\s+/, $data;

      my $states = {
         R => 'run',
         S => 'sleep',
         D => 'disk sleep',
         Z => 'defunct',
         T => 'stop',
         W => 'paging',
      };

      # See cygwin/fhandler_process.cc for the order
      my $stat_loc = [ qw(
         pid fname state ppid pgrp sess ttynum . flags minflt cminflt majflt cmajflt
         utime stime cutime cstime priority . . . . size rss .
      ) ];

      foreach my $i (0 .. @data - 1) {
         next if $stat_loc->[$i] eq '.';
         last if ($i >= @$stat_loc);
         $hash->{ $stat_loc->[$i] } = $data[$i];
      }

      $hash->{fname} =~ s/^\((.+)\)$/$1/;
      $hash->{state} = $states->{ $hash->{state} };
      $hash->{ time} = $hash->{ utime} + $hash->{ stime};
      $hash->{ctime} = $hash->{cutime} + $hash->{cstime};

      $hash->{ ttlflt} = $hash->{ minflt} + $hash->{ majflt};
      $hash->{cttlflt} = $hash->{cminflt} + $hash->{cmajflt};
   }

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
   my $posix2wm = [
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

Class::Method::Modifiers::around priority => sub {
   my ($orig, $self, $pri) = @_;
   return $orig->($self) if @_ == 2;

   $self->_win32_proc->SetPriorityClass($pri);
   $self->_set_priority($pri);
};

42;
