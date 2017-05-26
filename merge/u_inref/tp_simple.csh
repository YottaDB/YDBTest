#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"  
source $gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -dir << aaa
d ^mrgstp
halt
aaa
$gtm_tst/com/dbcheck.csh  -extr
