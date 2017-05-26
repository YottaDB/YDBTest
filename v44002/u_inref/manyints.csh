#
source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
w !,"Do cmmit^manyints",! d cmmit^manyints
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
$GTM<<EOF
w !,"Do rollbck^manyints",! d rollbck^manyints
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
#
$gtm_tst/com/dbcheck.csh -extract



