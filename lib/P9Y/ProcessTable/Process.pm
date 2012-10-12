package P9Y::ProcessTable::Process;

# VERSION
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
   handles  => [qw( _process_hash )],
);

has pid      => ( is => 'ro',  required  => 1 );
has uid      => ( is => 'rwp', predicate => 1 );
has gid      => ( is => 'rwp', predicate => 1 );
has euid     => ( is => 'rwp', predicate => 1 );
has egid     => ( is => 'rwp', predicate => 1 );
has ppid     => ( is => 'rwp', required  => 1 );
has pgrp     => ( is => 'rwp', predicate => 1 );
has sess     => ( is => 'rwp', predicate => 1 );

has cwd      => ( is => 'rwp', predicate => 1 );
has exe      => ( is => 'rwp', predicate => 1 );
has root     => ( is => 'rwp', predicate => 1 );
has cmdline  => ( is => 'rwp', predicate => 1 );
has environ  => ( is => 'rwp', predicate => 1 );

has fname    => ( is => 'rwp', predicate => 1 );
has state    => ( is => 'rwp', predicate => 1 );
has ttynum   => ( is => 'rwp', predicate => 1 );
has flags    => ( is => 'rwp', predicate => 1 );
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
has threads  => ( is => 'rwp', predicate => 1 );
has size     => ( is => 'rwp', predicate => 1 );
has rss      => ( is => 'rwp', predicate => 1 );
has wchan    => ( is => 'rwp', predicate => 1 );
has cpuid    => ( is => 'rwp', predicate => 1 );
has pctcpu   => ( is => 'rwp', predicate => 1 );
has pctmem   => ( is => 'rwp', predicate => 1 );

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
