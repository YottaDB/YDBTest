source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
w !,"Do cmmit^refniosv",! d cmmit^refniosv
h
EOF
#
$GTM<<EOF
w !,"Do rollbck^refniosv",! d rollbck^refniosv
h
EOF
#
$gtm_tst/com/dbcheck.csh -extract
