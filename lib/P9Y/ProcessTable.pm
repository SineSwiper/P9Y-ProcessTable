package P9Y::ProcessTable;

# VERSION
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
      when (/bsd$/) {
         require P9Y::ProcessTable::BSD;
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
