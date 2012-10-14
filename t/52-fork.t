use Config;
use Test::Most (
   $Config{d_fork} ?
   (tests => 4) :
   (skip_all => "Real forks needed for test")
);
use P9Y::ProcessTable;

# fork a child process
if (my $child_pid = fork) {
   # parent, fork returned PID of the child process
   my $p = P9Y::ProcessTable->process($child_pid);
   
   die_on_fail;
   ok($p, 'child exists');
   ok($p->pid == $child_pid, 'pid == pid');
   restore_fail;
   
   lives_ok { $p->kill(9) } 'child killed';
   sleep 2;
   $p = P9Y::ProcessTable->process($child_pid);
   ok(!$p, "child doesn't exist");
}
else {
   # child, fork returned 0
   # child process will be killed soon
   sleep 10000;
}
