package  # hide from PAUSE
   P9Y::ProcessTable;

our $VERSION = '1.00'; # VERSION

#############################################################################
# Modules

# use sanity;
use strict qw(subs vars);
no strict 'refs';
use warnings FATAL => 'all';
no warnings qw(uninitialized);

use base 'P9Y::ProcessTable::Base';

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

sub fields {
   return ( qw/
      pid uid gid euid egid suid sgid ppid pgrp sess
      cmdline
      utime stime start time
      priority fname state ttynum ttydev flags size rss wchan cpuid pctcpu pctmem
   / );
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
   # (only has the ones that are different)
   my $stat_loc = { qw/
      cmdline   cmndline
   / };

   no strict 'refs';
   foreach my $key ( $self->fields ) {
      my $old = $stat_loc->{$key} || $key;
      my $item = $info->$old();
      $hash->{$key} = $item if defined $item;
   }

   return $hash;
}

42;
