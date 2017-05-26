source $gtm_tst/com/dbcreate.csh mumps
#
$GTM<<EOF
w !,"Do cmmit^nointrpt",! d cmmit^nointrpt
h
EOF
#
$GTM<<EOF
w !,"Do cmmitd^nointrpt",! d cmmitd^nointrpt
h
EOF
#
$GTM<<EOF
w !,"Do rollbck^nointrpt",! d rollbck^nointrpt
h
EOF
#
$gtm_tst/com/dbcheck.csh -extract
