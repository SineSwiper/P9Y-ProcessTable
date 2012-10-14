package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '0.90'; # VERSION
# ABSTRACT: Darwin/OSX process table

#############################################################################
# Modules

use sanity;
use Moo;
use P9Y::ProcessTable::Process;

use Proc::ProcessTable;
use List::AllUtils 'first';

use namespace::clean;
no warnings 'uninitialized';

my $pt = Proc::ProcessTable->new();

#############################################################################
# Methods

# Unfortunately, P:PT has no concept of anything except "grab everything at once". So, we need to run
# through these wasteful cycles just to get one process, one list of PIDs, etc.

no warnings 'redefine';

sub table {
   my $self = shift;
   return map { 
      my $hash = $self->_convert_hash($_);
      $hash->{_pt_obj} = $self;
      P9Y::ProcessTable::Process->new($hash);
   } ($pt->table);
}

sub list {
   my $self = shift;
   return sort { $a <=> $b } map { $_->pid } @{ $pt->table };
}

sub _process_hash {
   my ($self, $pid) = @_;
   my $info = first { $_->pid == $pid } @{ $pt->table };
   return unless $info;
   return $self->_convert_hash;
}

sub _convert_hash {
   my ($self, $info) = @_;
   return unless $info;
   
   my $hash = {};
   state $stat_loc = { qw/
      pid       pid     
      ppid      ppid    
      pgrp      pgrp    
      uid       uid     
      gid       gid     
      euid      euid    
      egid      egid    
      suid      suid    
      sgid      sgid    
      priority  priority
      size      size    
      rss       rss     
      flags     flags   
      nice      nice    
      sess      sess    
      time      time    
      stime     stime   
      utime     utime   
      start     start   
      wchan     wchan   
      ttydev    ttydev  
      ttynum    ttynum  
      pctcpu    pctcpu  
      pctmem    pctmem  
      state     state   
      cmdline   cmndline
      fname     fname   
   / };
   
   foreach my $key (keys %$stat_loc) {
      no strict 'refs';
      my $old = $stat_loc->{$key};
      my $item = $info->$old();
      $hash->{$key} = $item if defined $item;
   }
   
   $hash->{ ttlflt} = $hash->{ minflt} + $hash->{ majflt};
   $hash->{cttlflt} = $hash->{cminflt} + $hash->{cmajflt};
   
   return $hash;
}

42;

__END__
=pod

=encoding utf-8

=head1 NAME

P9Y::ProcessTable - Darwin/OSX process table

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

