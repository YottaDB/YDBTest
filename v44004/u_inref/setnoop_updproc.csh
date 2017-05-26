#!/usr/local/bin/tcsh
# Test that even if the set noop optimization is enabled, it is disabled for updproc
setenv tst_jnl_str "$tst_jnl_str,epoch=1"
$gtm_tst/com/dbcreate.csh .
setenv gtm_gvdupsetnoop "1"
$GTM << EOF
for i=1:1:100 set ^a=1 hang 2
halt
EOF
$gtm_tst/com/RF_sync.csh
# get number of PBLK's on primary
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/get_pblk_count.csh PRI"
# get number of PBLK's on secondary
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/get_pblk_count.csh SEC"
$gtm_tst/com/dbcheck.csh
