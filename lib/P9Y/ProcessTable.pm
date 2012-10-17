package P9Y::ProcessTable;

our $VERSION = '0.91'; # VERSION
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

    use P9Y::ProcessTable;
 
    my @process_table = P9Y::ProcessTable->table;
    print $process_table[0]->pid."\n";
 
    my @pids = P9Y::ProcessTable->list;
 
    my $perl_process  = P9Y::ProcessTable->process;
    my $other_process = P9Y::ProcessTable->process($pid[0]);
 
    if ($other_process->has_threads) {
       print "# of Threads: ".$other_process->threads."\n";
       sleep 2;
       $other_process->refresh;
       print "# of Threads: ".$other_process->threads."\n";
    }
 
    # A cheap and sleazy version of ps
    my $FORMAT = "%-6s %-10s %-8s %-24s %s\n";
    printf($FORMAT, "PID", "TTY", "STAT", "START", "COMMAND");
    foreach my $p ( P9Y::ProcessTable->table ) {
       printf($FORMAT,
          $p->pid,
          $p->ttydev,
          $p->state,
          scalar(localtime($p->start)),
          $p->cmdline,
       );
    }
 
    # Dump all the information in the current process table
    no strict 'refs';
    foreach my $p ( P9Y::ProcessTable->table ) {
       print "--------------------------------\n";
       foreach my $f (P9Y::ProcessTable->fields) {
          my $has_f = 'has_'.$f;
          print $f, ":  ", $p->$f(), "\n" if ( $p->$has_f() );
       }
    }

=head1 DESCRIPTION

This interface will portably access the process table, no matter what the OS, and normalize its outputs to work similar across all platforms.

=head1 METHODS

All methods to this module are actually class-based (objectless) calls.  However, the L<P9Y::ProcessTable::Process> returns are actual objects.

=head2 fields

Returns a list of the field names supported by the module on the current architecture.

=head2 list

Returns a list of PIDs that are available in the process table.  On most systems, this is a less heavy call than C<<< table >>>, as it doesn't have to
look up the information for every single process.

=head2 table

Returns a list of L<P9Y::ProcessTable::Process> objects for all of the processes in the process table.  (More information in that module POD.)

=head2 process

Returns a L<P9Y::ProcessTable::Process> object for the process specified.  If a process isn't specified, it will look up C<<< $$ >>> (or its platform
equivalent).

=head1 P9Y?

Portability.  You know, like I18N and L10N.

=head1 SUPPORTED PLATFORMS

Currently, this module supports:

=over

=item *

All C<<< /proc >>> friendly OSs to some degree.  Linux and Solaris are fully supported so far.

=item *

Windows (most flavors)

=item *

Darwin (see CAVEATS)

=item *

FreeBSD (only; see CAVEATS)

=item *

OSE<sol>2 (hey, the module was there...)

=item *

VMS (same here; probably needs some testing)

=back

=head1 HISTORY

This module spawned because L<Proc::ProcessTable> has fallen into L<bugland|http://matrix.cpantesters.org/?dist=Proc-ProcessTable-0.45> for the
last 4 years, and many people just want to be able to get a simple C<<< PID+cmdline >>> from the process table.  While this module offers more than
that as a bonus, the goal of this module is to have something that JFW, and continues to JFW.

With that in mind, here my list of what went wrong with L<Proc::ProcessTable>.  I have nothing against the authors of that module, but I feel like
we should try to learn from our failures and adapt in kind.

=over

=item *

B<Too many OSs in one distribution.>  I dunno about you, but I don't happen to have 15 different OSs on VMs anywhere.  At best, I might have 
access to 2-3 different platforms.  So, trying to test out code on a platform that you don't actually own is especially difficult.

Thus, this module is merely a wrapper around various other modules that provide process table information.  Those guys actually have the means
(and the drive) to test their stuff on those OSs.  (The sole exception is the ProcFS module, but that may get split eventually.)

=back

=over

=item *

B<Too much CE<sol>XS code.>  The C and XS code falls in a class of exclusivity that makes it even harder to maintain.  If I were to conjure up some
wild guess, I would say that only 20% of Perl programmers could actually read, understand, and program CE<sol>XS code.  People aren't calling the
process table a 1000 times a second, so there's really no need for a speed boost, either.

Alas, sometimes this is unavoidable, with the process information buried in C library calls.  However, the C<<< /proc >>> FS is available on a great
many amount of UNIX platforms, so it should be used I<as much as possible>.  Also, I take this moment to shake my tiny little fist at the BSD
folks for actually B<regressing> the OS by removing support for C<<< /proc >>>.  All of the reasons behind it are unsound or have solutions that don't
involve removing this most basic right of UNIX users.

=back

=head1 CAVEATS E<sol> TODO

=over

=item *

No support for any non-proc BSD system other than FreeBSD.  This is because L<BSD::Process> only supports FreeBSD.  If the support is needed,
bug that module maintainer and provide some patches.  Then bug me and I'll change the OS detection logic.

=back

=over

=item *

This thing actually uses L<Proc::ProcessTable> for DarwinE<sol>OSX systems.  Darwin doesn't have a C<<< /proc >>> access point (BSD... sigh).  Fortunately,
P:PT is passing all Darwin tests (so far), so until somebody splits the code from that to a new module (hint hint)...

=back

=over

=item *

Certain other C<<< /proc >>> friendly OSs needs further support.  Frankly, I'm trying to get a feel for what people actually need than just spending 
the time coding something for, say, NeXT OS and 50 other flavors.  However, supporting one OS or another should be pretty easy.  If you need
support, dive into the C<<< ProcFS >>> code and submit a patch.

=back

=over

=item *

See L<P9Y::ProcessTable::Process> for other caveats.

=back

=head1 SEE ALSO

=over

=item *

L<Proc::ProcessTable>

=item *

L<BSD::Process>

=item *

L<Win32::Process::Info> & L<Win32::Process>

=item *

L<OS2::Process>

=item *

L<VMS::Process>

=back

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

