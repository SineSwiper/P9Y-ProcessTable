package P9Y::ProcessTable::Process;

# VERSION
# ABSTRACT: Base class for a single process

#############################################################################
# Modules

use strict;
use warnings;

use Module::Runtime ();

use Moo;

# Figure out which OS role we should consume (if any)
my %OS_TRANSLATE = (
   cygwin => 'MSWin32',
);

my $role = 'P9Y::ProcessTable::Role::Process::OS::'.($OS_TRANSLATE{$^O} || $^O);

$@ = '';
eval { Module::Runtime::require_module($role) } || do { $role = ''; };
die $@ if $@ and $@ !~ /^Can't locate /;

# This here first, so that it gets overloaded
extends 'P9Y::ProcessTable::Process::Base';

with $role if $role;

42;

__END__

=begin wikidoc

= SYNOPSIS

   use P9Y::ProcessTable;

   my $p = P9Y::ProcessTable->process;
   foreach my $f (P9Y::ProcessTable->fields) {
      my $has_f = 'has_'.$f;
      print $f, ":  ", $p->$f(), "\n" if ( $p->$has_f() );
   }

= DESCRIPTION

This (Moo) class/object represents a single process.

= METHODS

== fields

Same as the one from [P9Y::ProcessTable].

== refresh

This refreshes the data for this process.  Besides construction (via [P9Y::ProcessTable]), this is the only method that refreshes the data set.
So, don't expect a call to, say, {utime} to actually look up the latest value from the OS.

== kill

Sends the signal specified to the process.  For Windows, this is somewhat normalized, so a {$p->kill(9)} will terminate the process.

== pgrp / priority

Unlike the other data methods (below), these two are settable by passing a value.  In most cases, this calls the {set*} command from CORE.

== Process data methods

Depending on the OS, the following methods are available.  Also, all methods also have a {has_*} predicate, except for {pid}.

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

   winpid    (Cygwin only) Windows PID
   winexe    (Cygwin only) Windows Executable path

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

Make no assumptions about what is available and what is not, not even {ppid}.  Instead, use the {has_*} methods and plan for alternatives
if that data isn't available.

= CAVEATS

* Certain fields might not be normalized correctly.  Patches welcome!

* Until [Win32::API] is [fixed|https://github.com/bulk88/perl5-win32-api], {kill} can't do graceful {WM_CLOSE} call to processes on Windows.

=end wikidoc
