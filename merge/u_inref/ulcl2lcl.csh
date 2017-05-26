#!/usr/local/bin/tcsh -f
$switch_chset UTF-8
setenv test_reorg "NON_REORG"  
$GTM < $gtm_tst/$tst/u_inref/ulcl2lcl.input
