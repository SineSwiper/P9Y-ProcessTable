package  # hide from PAUSE
   P9Y::ProcessTable;

# VERSION
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
