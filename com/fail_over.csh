#!/usr/local/bin/tcsh -f
#
# Fail over 
# Interchange roll of primary and secondary
#

$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/portno_release.csh"
$pri_shell "$pri_getenv; cd $PRI_SIDE; rm -f *.o >& /dev/null"
$sec_shell "$sec_getenv; cd $SEC_SIDE; rm -f *.o >& /dev/null"
setenv tmp "$sec_shell"
setenv sec_shell "$pri_shell"
setenv pri_shell "$tmp"
setenv tmp "$sec_getenv"
setenv sec_getenv "$pri_getenv"
setenv pri_getenv "$tmp"
setenv tmp "$PRI_SIDE"
setenv PRI_SIDE "$SEC_SIDE"
setenv SEC_SIDE "$tmp"
setenv tmp "$tst_now_primary"
setenv tst_now_primary "$tst_now_secondary"
setenv tst_now_secondary "$tmp"
setenv tmp "$gtm_test_cur_pri_name"
setenv gtm_test_cur_pri_name "$gtm_test_cur_sec_name"
setenv gtm_test_cur_sec_name "$tmp"
setenv tmp "$test_jnldir"
setenv test_jnldir "$test_remote_jnldir"
setenv test_remote_jnldir "$tmp"
setenv tmp "$test_bakdir"
setenv test_bakdir "$test_remote_bakdir"
setenv tst_remote_bakdir "$tmp"
setenv start_time `date +%H_%M_%S`
setenv SRC_LOG_FILE "$PRI_SIDE/SRC_${start_time}.log"
setenv RCVR_LOG_FILE "$SEC_SIDE/RCVR_${start_time}.log"
setenv PASSIVE_LOG_FILE "$SEC_SIDE/passive_${start_time}.log"
setenv UPD_LOG_FILE "$SEC_SIDE/UPDPROC_${start_time}.log"
if ($tst_org_host != $tst_remote_host) $gtm_tst/com/send_env.csh
$sec_shell "$sec_getenv; cd $SEC_SIDE; if (-e portno) mv portno portno_before_fail_over"
setenv portno `$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_acquire.csh"`
$sec_shell "$sec_getenv; cd $SEC_SIDE; echo $portno >&! portno"
