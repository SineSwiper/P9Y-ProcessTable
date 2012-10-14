package P9Y::ProcessTable;

our $VERSION = '0.90'; # VERSION
# ABSTRACT: Portably access the process table

use sanity;

use Path::Class;
use namespace::clean;

BEGIN {
   # Figure out which OS module we should use
   for (lc $^O) {
      when (/mswin32|cygwin/) {
         require P9Y::ProcessTable::Win32;
      }
      # BSD::Process currently only supports FreeBSD;
      # fall by on /proc for the others
      when ('freebsd') {
         require P9Y::ProcessTable::BSD;
      }
      when ('darwin') {
         require P9Y::ProcessTable::Darwin;
      }
      when ('os2') {
         require P9Y::ProcessTable::OS2;
      }
      when ('vms') {
         require P9Y::ProcessTable::VMS;
      }
      when ('dos') {
         die "Heh, DOS processes... you're funny!";
      }
      default {
         # let's hope they have /proc
         if ( -d dir('', 'proc') ) {
            require P9Y::ProcessTable::ProcFS;
         }
         else {
            die "No idea how to handle $^O processes.  Email me with more information!";
         }
      }
   }
}

#############################################################################
# Common Methods (may potentially be redefined with OS-specific ones)

no warnings 'redefine';

sub table {
   my $self = shift;
   return map { $self->process($_) } ($self->list);
}

sub process {
   my ($self, $pid) = @_;
   $pid = $$ if (@_ == 1);
   my $hash = $self->_process_hash($pid);
   return unless $hash;
   
   $hash->{_pt_obj} = $self;
   return P9Y::ProcessTable::Process->new($hash);
}

42;



=pod

=encoding utf-8

=head1 NAME

P9Y::ProcessTable - Portably access the process table

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

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Internet Relay Chat

You can get live help by using IRC ( Internet Relay Chat ). If you don't know what IRC is,
please read this excellent guide: L<http://en.wikipedia.org/wiki/Internet_Relay_Chat>. Please
be courteous and patient when talking to us, as we might be busy or sleeping! You can join
those networks/channels and get help:

=over 4

=item *

irc.perl.org

You can connect to the server at 'irc.perl.org' and join this channel: #distzilla then talk to this person for help: SineSwiper.

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests via L<L<https://github.com/SineSwiper/P9Y-ProcessTable/issues>|GitHub>.

=head1 AUTHOR

Brendan Byrd <BBYRD@CPAN.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Brendan Byrd.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

