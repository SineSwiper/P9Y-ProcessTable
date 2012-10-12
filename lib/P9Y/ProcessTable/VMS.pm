package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.90'; # VERSION
# ABSTRACT: VMS process table

#############################################################################
# Modules

use sanity;
use Moo;
use P9Y::ProcessTable::Process;

use VMS::Process;

use namespace::clean;
no warnings 'uninitialized';

#############################################################################
# Methods

sub table {
   my $self = shift;
   return map { 
      my $hash = $self->_convert_hash($_);
      $hash->{_pt_obj} = $self;
      P9Y::ProcessTable::Process->new($hash);
   } (process_list);
}

sub list {
   my $self = shift;
   return sort { $a <=> $b } map { $_->{PID} } (process_list);
}

sub _process_hash {
   my ($self, $pid) = @_;
   my $info = process_list({
      NAME  => 'MASTER_PID',
      VALUE => $pid,
   });
   return unless $info;
   return $self->_convert_hash;
}

sub _convert_hash {
   my ($self, $info) = @_;
   return unless $info;
   
   my $hash = {};
   state $stat_loc = { qw/
      pid         PID
      uid         OWNER
      gid         GRP
      ppid        MASTER_PID
      pgrp        MASTER_PID
      cpuid       CPUID
      priority    PRI
      flags       PHDFLAGS
      minflt      PAGEFLTS
      time        CPUTIM
      size        VIRTPEAK
      rss         WSSIZE
      ttydev      TT_PHYDEVNAM
      fname       PRCNAM
      start       LOGINTIM
      state       STATE

      exe         IMAGNAME
   / };

   foreach my $key (keys %$stat_loc) {
      my $item = $info->{ $stat_loc->{$key} };
      $hash->{$key} = $item if defined $item;
   }

   return $hash;
}

42;



=pod

=encoding utf-8

=head1 NAME

P9Y::ProcessTable - VMS process table

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

