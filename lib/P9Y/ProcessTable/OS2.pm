package  # hide from PAUSE
   P9Y::ProcessTable;

# VERSION
# ABSTRACT: OS/2 process table

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
