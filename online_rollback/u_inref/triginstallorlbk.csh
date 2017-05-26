#!/usr/local/bin/tcsh -f
#GTM-7164
#    ORLBK : online_rollback : mupip trigger operations should be hit with a DBROLLEDBACK
setenv gtm_test_trigger 1
setenv test_specific_trig_file $gtm_tst/com/imptp.trg


$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 5 125 1000 1024 4096 1024 4096

$echoline
echo "Start source server with journaling enabled"
$MSR STARTSRC INST1 INST2 RP

$gtm_exe/mumps -run triginstallorlbk
# wait for the background jobs to complete
set pid=`$tst_awk -F"=" '/^PID/{print $NF;exit}' trigger_triginstallorlbk0.mjo1`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 600

$echoline
echo "Start receiver server with journaling enabled"
$MSR STARTRCV INST1 INST2
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck_filter.csh -extract
