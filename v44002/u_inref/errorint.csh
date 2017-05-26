source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
w !,"Do errcmmt^errorint",! d errcmmt^errorint
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
#
$GTM<<EOF
w "Do errlbck^errorint",! d errlbck^errorint
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
$gtm_tst/com/dbcheck.csh -extract


