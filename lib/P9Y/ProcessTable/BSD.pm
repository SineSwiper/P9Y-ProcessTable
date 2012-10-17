package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.91'; # VERSION

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

sub fields {
   return ( qw/
      pid uid gid euid suid sgid ppid pgrp sess
      exe
      minflt cminflt majflt cmajflt ttlflt cttlflt utime stime cutime cstime start time ctime
      priority fname state flags size rss wchan cpuid pctcpu
   / );
}

sub _process_hash {
   my ($self, $pid) = @_;
   my $info = BSD::Process::info($pid);
   return unless $info;

   my $hash = {};

   # (only has the ones that are different)
   state $stat_loc = { qw/
      uid         ruid
      gid         rgid
      euid        uid
      suid        svuid
      sgid        svgid
      pgrp        pgid
      sess        sid
      cpuid       oncpu
      priority    nice
      flags       flag
      cminflt     minflt_ch
      cmajflt     majflt_ch
      cutime      utime_ch
      cstime      stime_ch
      ctime       time_ch
      rss         rssize
      wchan       wmesg
      fname       comm
      exe         comm
   / };

   foreach my $key ( $self->fields ) {
      my $item = $info->{ $stat_loc->{$key} || $key };
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

__END__
=pod

=encoding utf-8

=head1 NAME

P9Y::ProcessTable

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

