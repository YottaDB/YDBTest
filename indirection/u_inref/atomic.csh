# longname test for atomic indirection
$gtm_tst/com/dbcreate.csh mumps 1 125
$GTM << \aaa
do ^atomic
halt
\aaa
$gtm_tst/com/dbcheck.csh
