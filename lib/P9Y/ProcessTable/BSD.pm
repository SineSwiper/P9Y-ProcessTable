package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.90'; # VERSION
# ABSTRACT: BSD process table

#############################################################################
# Modules

use sanity;
use Moo;
use P9Y::ProcessTable::Process;

use BSD::Process;

use namespace::clean;
no warnings 'uninitialized';

#############################################################################
# Methods

sub list {
   my $self = shift;
   return sort { $a <=> $b } (BSD::Process::list);
}

sub _process_hash {
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
   
   $hash->{ ttlflt} = $hash->{ minflt} + $hash->{ majflt};
   $hash->{cttlflt} = $hash->{cminflt} + $hash->{cmajflt};

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



=pod

=encoding utf-8

=head1 NAME

P9Y::ProcessTable - BSD process table

=head1 SYNOPSIS

    # code

=head1 DESCRIPTION

### Ruler ##################################################################################################################################12345

Insert description here...

=head1 CAVEATS

### Ruler ##################################################################################################################################12345

Bad stuff...

=head1 SEE ALSO

### Ruler ##################################################################################################################################12345

Other modules...

=head1 ACKNOWLEDGEMENTS

### Ruler ##################################################################################################################################12345

Thanks and stuff...

=head1 AVAILABILITY

The project homepage is L<https://github.com/SineSwiper/P9Y-ProcessTable/wiki>.

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<https://metacpan.org/module/P9Y::ProcessTable/>.

=head1 AUTHOR

Brendan Byrd <BBYRD@CPAN.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Brendan Byrd.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

