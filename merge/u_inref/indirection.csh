#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"  
source $gtm_tst/com/dbcreate.csh mumps 2
$gtm_exe/mumps -dir << aaa
d ^MINDR1
d ^MINDR2
d ^MINDR3
d ^MINDR4
d ^MINDMISC
halt
aaa
$gtm_tst/com/dbcheck.csh  -extr
