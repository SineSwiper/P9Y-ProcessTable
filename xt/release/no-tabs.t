use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.08

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/P9Y/ProcessTable.pm',
    'lib/P9Y/ProcessTable/Process.pm',
    'lib/P9Y/ProcessTable/Process/Base.pm',
    'lib/P9Y/ProcessTable/Role/Process/OS/MSWin32.pm',
    'lib/P9Y/ProcessTable/Role/Table/OS/MSWin32.pm',
    'lib/P9Y/ProcessTable/Role/Table/OS/VMS.pm',
    'lib/P9Y/ProcessTable/Role/Table/OS/freebsd.pm',
    'lib/P9Y/ProcessTable/Role/Table/OS/os2.pm',
    'lib/P9Y/ProcessTable/Role/Table/PPT.pm',
    'lib/P9Y/ProcessTable/Role/Table/ProcFS.pm',
    'lib/P9Y/ProcessTable/Table.pm',
    'lib/P9Y/ProcessTable/Table/Base.pm',
    't/00-check-deps.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/00-report.t',
    't/51-basic.t',
    't/52-fork.t'
);

notabs_ok($_) foreach @files;
done_testing;
