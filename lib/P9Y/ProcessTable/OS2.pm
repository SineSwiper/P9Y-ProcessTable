package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.91'; # VERSION

#############################################################################
# Modules

use sanity;
use Moo;
use P9Y::ProcessTable::Process;

use OS2::Process;

use namespace::clean;
no warnings 'uninitialized';

#############################################################################
# Methods

no warnings 'redefine';

sub table {
   my $self = shift;
   return map { 
      my $hash = $self->_convert_hash($_);
      $hash->{_pt_obj} = $self;
      P9Y::ProcessTable::Process->new($hash);
   } (process_hentries);
}

sub list {
   my $self = shift;
   return sort { $a <=> $b } map { $_->{owner_pid} } (process_hentries);
}

sub fields {
   return ( qw/
      pid ppid sess cmdline
   / );
}

sub _process_hash {
   my ($self, $pid) = @_;
   my $info = process_hentry($pid);
   return unless $info;
   return $self->_convert_hash;
}

sub _convert_hash {
   my ($self, $info) = @_;
   return unless $info;
   
   my $hash = {};
   state $stat_loc = { qw/
      pid        owner_pid
      sess       owner_sid
      cmdline    title
   / };
   
   foreach my $key (keys %$stat_loc) {
      my $item = $info->{ $stat_loc->{$key} };
      $hash->{$key} = $item if defined $item;
   }
      
   $hash->{ppid} = ppidOf($hash->{pid});
   
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

