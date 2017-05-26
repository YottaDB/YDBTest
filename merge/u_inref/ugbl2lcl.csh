#!/usr/local/bin/tcsh -f
$switch_chset UTF-8
setenv test_reorg "NON_REORG"  
source $gtm_tst/com/dbcreate.csh mumps 4 255 1000
$GTM < $gtm_tst/$tst/u_inref/ugbl2lcl.input
$gtm_tst/com/dbcheck.csh  -extr
