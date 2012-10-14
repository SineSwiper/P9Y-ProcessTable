use Test::Most tests => 3;
use P9Y::ProcessTable;

my @tbl;
die_on_fail;
lives_ok { @tbl = P9Y::ProcessTable->table } 'get table';
cmp_ok(@tbl, '>', 5, 'more than 5 processes');

my $p = P9Y::ProcessTable->process();
always_explain $p;
ok($p, 'process exists');