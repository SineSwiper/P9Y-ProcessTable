package P9Y::ProcessTable;

# VERSION
# ABSTRACT: Portably access the process table

#############################################################################
# Modules

use sanity;

use Path::Class;
use Class::Load 'load_class';

use namespace::clean;
no warnings 'uninitialized';

#############################################################################
# Pre/post-BUILD

sub new {
   # Figure out which OS module we should use
   for (lc $^O) {
      when (/mswin32|cygwin/) {
         load_class 'P9Y::ProcessTable::Win32';
         return P9Y::ProcessTable::Win32->new();
      }
      when (/bsd$/) {
         load_class 'P9Y::ProcessTable::BSD';
         return P9Y::ProcessTable::BSD->new();
      }
      when ('os2') {
         load_class 'P9Y::ProcessTable::OS2';
         return P9Y::ProcessTable::OS2->new();
      }
      when ('vms') {
         load_class 'P9Y::ProcessTable::VMS';
         return P9Y::ProcessTable::VMS->new();
      }
      when ('dos') {
         die "Heh, DOS processes... you're funny!";
      }
      default {
         # let's hope they have /proc
         if ( -d dir('', 'proc') ) {
            load_class 'P9Y::ProcessTable::ProcFS';
            return P9Y::ProcessTable::ProcFS->new();
         }
      }
   }

   die "No idea how to handle $^O processes.  Email me with more information!";
};

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
