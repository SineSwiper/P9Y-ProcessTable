package P9Y::ProcessTable;

# VERSION
# ABSTRACT: BSD process table

#############################################################################
# Modules

use sanity;
use Moo;

use BSD::Process;

use namespace::clean;
no warnings 'uninitialized';

#############################################################################
# Methods

sub table {
   my $self = shift;
   return map { $self->process($_) } ($self->list);
}

sub list {
   my $self = shift;
   return sort { $a <=> $b } (BSD::Process::list);
}

sub process {
   my ($self, $pid) = @_;
   my $info = BSD::Process::info($pid);
   return unless $info;
   
   my $hash = {};
   
   state $stat_loc = { qw/
      pid         pid
      uid         ruid
      gid         rgid
      euid        uid
      egid        svgid
      ppid        ppid
      pgrp        pgid
      sess        sid
      cpuid       oncpu
      priority    nice
      flags       flag
      minflt      minflt
      cminflt     minflt_ch
      majflt      majflt
      cmajflt     majflt_ch
      utime       utime
      stime       stime
      cutime      utime_ch
      cstime      stime_ch
      time        time
      ctime       time_ch
      size        size
      rss         rssize
      wchan       wmesg
      fname       comm
      start       start
      pctcpu      pctcpu
      exe         comm
   / };
   
   foreach my $key (keys %$stat_loc) {
      my $item = $info->{ $stat_loc->{$key} };
      $hash->{$key} = $item if defined $item;
   }

   state $states = {
      stat_1 => 'forking',
      stat_2 => 'run',
      stat_3 => 'sleep',
      stat_4 => 'stop',
      stat_5 => 'defunct',
      stat_6 => 'wait',
      stat_7 => 'disk sleep',
   };
   
   my @state;
   foreach my $key (keys $states) {
      push @state, $states->{$key} if $info->{$key};
   }
   $hash->{state} = join ' ', @state;
   
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
