#
source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
w !,"Do cmmit^nesttp",! d cmmit^nesttp
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
$GTM<<EOF
w !,"Do rollbck1^nesttp",! d rollbck1^nesttp
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
$GTM<<EOF
w !,"Do rollbck2^nesttp",! d rollbck2^nesttp
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
$GTM<<EOF
w !,"Do rollbck3^nesttp",! d rollbck3^nesttp
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
#
$gtm_tst/com/dbcheck.csh -extract


