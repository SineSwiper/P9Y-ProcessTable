package P9Y::ProcessTable::Table;

# VERSION

#############################################################################
# Modules

use strict;
use warnings;

use Devel::SimpleTrace;

use Path::Class ();

use Moo;

# This here first, so that it gets overloaded
extends 'P9Y::ProcessTable::Table::Base';

# Figure out which OS role we should consume
my ($role_base, $role);
BEGIN {
   $role_base = 'P9Y::ProcessTable::Role::Table::';
   $role      = 'OS::'.$^O;

   ( my $os_path = $role_base.$role.'.pm' ) =~ s{::}{/}g;

   my $has_os_role = eval { require $os_path };

   unless ($has_os_role) {
      # let's hope they have /proc
      if ( -d Path::Class::dir( '', 'proc' ) ) { $role = 'ProcFS'; }

      # ...or that Proc::ProcessTable can handle it
      else                                     { $role = 'PPT';    }
   }
}

with $role_base.$role;

use P9Y::ProcessTable::Process;

42;
