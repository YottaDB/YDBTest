#!/usr/local/bin/tcsh -f
# 
# GTM-7497. Trigger using indirection can get INDMAXNEST if trigger restarts many times due to contention
#
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << GTM_EOF
	do test4^gtm7497
GTM_EOF
$gtm_tst/com/dbcheck.csh
