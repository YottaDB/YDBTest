#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"  
source $gtm_tst/$tst/u_inref/cre_coll_sl.csh  
setenv gtm_test_parms "1,7"
setenv gtm_test_maxdim 3
source $gtm_tst/com/dbcreate.csh mumps 7 255 1010 4096 4096 4096 -col=1 
$gtm_exe/mumps -dir << aaa
d ^MRGITP
zwr ^a
halt
aaa
$gtm_tst/com/dbcheck.csh  -extr
cat *.mje*
