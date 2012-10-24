package P9Y::ProcessTable::Process;

our $VERSION = '0.93'; # VERSION
# ABSTRACT: Base class for a single process

#############################################################################
# Modules

use sanity;
use Moo;

use namespace::clean;
no warnings 'uninitialized';

#############################################################################
# Attributes

has _pt_obj  => (
   is       => 'ro',
   required => 1,
   handles  => [qw( 
      fields
      _process_hash
   )],
);

has pid      => ( is => 'ro',  required  => 1 );
has uid      => ( is => 'rwp', predicate => 1 );
has gid      => ( is => 'rwp', predicate => 1 );
has euid     => ( is => 'rwp', predicate => 1 );
has egid     => ( is => 'rwp', predicate => 1 );
has suid     => ( is => 'rwp', predicate => 1 );
has sgid     => ( is => 'rwp', predicate => 1 );
has ppid     => ( is => 'rwp', predicate => 1 );
has pgrp     => ( is => 'rwp', predicate => 1 );
has sess     => ( is => 'rwp', predicate => 1 );

has cwd      => ( is => 'rwp', predicate => 1 );
has exe      => ( is => 'rwp', predicate => 1 );
has root     => ( is => 'rwp', predicate => 1 );
has cmdline  => ( is => 'rwp', predicate => 1 );
has environ  => ( is => 'rwp', predicate => 1 );

has minflt   => ( is => 'rwp', predicate => 1 );
has cminflt  => ( is => 'rwp', predicate => 1 );
has majflt   => ( is => 'rwp', predicate => 1 );
has cmajflt  => ( is => 'rwp', predicate => 1 );
has ttlflt   => ( is => 'rwp', predicate => 1 );
has cttlflt  => ( is => 'rwp', predicate => 1 );
has utime    => ( is => 'rwp', predicate => 1 );
has stime    => ( is => 'rwp', predicate => 1 );
has cutime   => ( is => 'rwp', predicate => 1 );
has cstime   => ( is => 'rwp', predicate => 1 );
has start    => ( is => 'rwp', predicate => 1 );
has time     => ( is => 'rwp', predicate => 1 );
has ctime    => ( is => 'rwp', predicate => 1 );

has priority => ( is => 'rwp', predicate => 1 );
has fname    => ( is => 'rwp', predicate => 1 );
has state    => ( is => 'rwp', predicate => 1 );
has ttynum   => ( is => 'rwp', predicate => 1 );
has ttydev   => ( is => 'rwp', predicate => 1 );
has flags    => ( is => 'rwp', predicate => 1 );
has threads  => ( is => 'rwp', predicate => 1 );
has size     => ( is => 'rwp', predicate => 1 );
has rss      => ( is => 'rwp', predicate => 1 );
has wchan    => ( is => 'rwp', predicate => 1 );
has cpuid    => ( is => 'rwp', predicate => 1 );
has pctcpu   => ( is => 'rwp', predicate => 1 );
has pctmem   => ( is => 'rwp', predicate => 1 );

#sub fields {
#   return ( qw/
#      pid uid gid euid egid suid sgid ppid pgrp sess
#      cwd exe root cmdline environ
#      minflt cminflt majflt cmajflt ttlflt cttlflt utime stime cutime cstime start time ctime
#      priority fname state ttynum ttydev flags threads size rss wchan cpuid pctcpu pctmem
#   / );
#}

#############################################################################
# Common Methods (may potentially be redefined with OS-specific ones)

sub refresh {
   my ($self) = @_;
   my $hash = $self->_process_hash($self->pid);
   return unless $hash;

   # use set methods
   foreach my $meth (keys %$hash) {
      no strict 'refs';
      $self->("_set_$meth")($hash->{$meth}) if (exists $hash->{$meth});
   }

   return $self;
}

sub kill {
   my ($self, $sig) = @_;
   return CORE::kill($sig, $self->pid);
}

sub pgrp {
   my ($self, $pgrp) = @_;
   return $self->{pgrp} if @_ == 1;
   
   setpgrp($self->pid, $pgrp);
   $self->_set_pgrp($pgrp);
}

sub priority {
   my ($self, $pri) = @_;
   return $self->{priority} if @_ == 1;
   
   setpriority(0, $self->pid, $pri);
   $self->_set_priority($pri);
}

42;



=pod

=encoding utf-8

=head1 NAME

P9Y::ProcessTable::Process - Base class for a single process

=head1 SYNOPSIS

    use P9Y::ProcessTable;
 
    my $p = P9Y::ProcessTable->process;
    foreach my $f (P9Y::ProcessTable->fields) {
       my $has_f = 'has_'.$f;
       print $f, ":  ", $p->$f(), "\n" if ( $p->$has_f() );
    }

=head1 DESCRIPTION

This (Moo) classE<sol>object represents a single process.

=head1 METHODS

=head2 fields

Same as the one from L<P9Y::ProcessTable>.

=head2 refresh

This refreshes the data for this process.  Besides construction (via L<P9Y::ProcessTable>), this is the only method that refreshes the data set.
So, don't expect a call to, say, C<<< utime >>> to actually look up the latest value from the OS.

=head2 kill

Sends the signal specified to the process.  For Windows, this is somewhat normalized, so a C<<< $p->kill(9) >>> will terminate the process.

=head2 pgrp E<sol> priority

Unlike the other data methods (below), these two are settable by passing a value.  In most cases, this calls the C<<< set* >>> command from CORE.

=head2 Process data methods

Depending on the OS, the following methods are available.  Also, all methods also have a C<<< has_* >>> predicate, except for C<<< pid >>>.

    pid       Process ID
    uid       UID of process
    gid       GID of process
    euid      Effective UID
    egid      Effective GID
    suid      Saved UID
    sgid      Saved GID
    ppid      Parent PID
    pgrp      Process group
    sess      Session ID
 
    cwd       Current working directory
    exe       Executable (with a full path)
    root      Process's root directory
    cmdline   Full command line
    environ   Environment variables for the process (as a HASHREF)
    fname     Filename (typically without a path)
 
    minflt    Minor page faults
    cminflt   Minor page faults of children
    majflt    Major page faults
    cmajflt   Major page faults of children
    ttlflt    Total page faults (min+maj; sometimes this is the only fault available)
    cttlflt   Total page faults of children
    utime     User mode time
    stime     Kernel/system mode time
    cutime    Child utime
    cstime    Child stime
    time      Total time (u+s; sometimes this is the only time available)
    ctime     Total time of children
    start     Start time of process (in epoch seconds)
 
    priority  Priority / Nice value
    state     State of process (with some level of normalization)
    ttynum    TTY number
    ttydev    TTY device name
    flags     Process flags (not normalized)
    threads   Number of threads/LWPs
    size      Virtual memory size (in bytes)
    rss       Resident/working set size (in bytes)
    wchan     Address of current system call
    cpuid     CPU ID of processor running on
    pctcpu    Percent CPU used
    pctmem    Percent memory used

Make no assumptions about what is available and what is not, not even C<<< ppid >>>.  Instead, use the C<<< has_* >>> methods and plan for alternatives
if that data isn't available.

=head1 CAVEATS

=over

=item *

Certain fields might not be normalized correctly.  Patches welcome!

=back

=over

=item *

Until L<Win32::API> is L<fixed|https://github.com/bulk88/perl5-win32-api>, C<<< kill >>> can't do graceful C<<< WM_CLOSE >>> call to processes on Windows.

=back

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

