#!/usr/local/bin/tcsh -f
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 1
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/change_head_updproc.csh"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/change_head_updproc.csh"
##
$GTM << aaa
do in0^pfill("set",1)
do in0^pfill("ver",1)
h
aaa
$gtm_tst/com/dbcheck.csh -extr
##
echo "Verify the updproc related file header fields"
$gtm_tst/$tst/u_inref/dse_dump_uprproc.csh
##
