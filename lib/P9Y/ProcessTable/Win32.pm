package P9Y::ProcessTable;

# VERSION
# ABSTRACT: Win32 process table

#############################################################################
# Modules

use sanity;
use Moo;

use Win32::Process::Info;

use namespace::clean;
no warnings 'uninitialized';

my $pi = Win32::Process::Info->new();

#############################################################################
# Methods

sub table {
   my $self = shift;
   return map { $self->process($_) } ($self->list);
}

sub list {
   my $self = shift;
   return sort { $a <=> $b } ($pi->ListPids);
}

sub process {
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
      minflt     PageFaults
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

42;

__END__

=begin wikidoc

= SYNOPSIS
 
   # code
 
= DESCRIPTION

### Ruler ##################################################################################################################################12345

Insert description here...

= CAVEATS

### Ruler ##################################################################################################################################12345

Bad stuff...

= SEE ALSO

### Ruler ##################################################################################################################################12345

Other modules...

= ACKNOWLEDGEMENTS

### Ruler ##################################################################################################################################12345

Thanks and stuff...

=end wikidoc
