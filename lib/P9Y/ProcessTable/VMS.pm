package P9Y::ProcessTable::VMS;

# VERSION
# ABSTRACT: VMS process table

#############################################################################
# Modules

use sanity;
use Moo;

use VMS::Process;

use namespace::clean;
no warnings 'uninitialized';

my $pi = Win32::Process::Info->new();

#############################################################################
# Methods

sub table {
   my $self = shift;
   return map { $self->process($_) } ($self->list);
}

sub list {
   my $self = shift;
   return sort { $a <=> $b } (BSD::Process::list);
}

sub process {
   my ($self, $pid) = @_;
   my $info = process_list({
      NAME  => 'MASTER_PID',
      VALUE => $pid,
   });
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
