#!/usr/local/bin/tcsh -f
#
# TEST : S9908-001327 Update process died on receiving TRETRY signal
#
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 2048 512 500
setenv start_time `cat start_time`
if (! $?helper_rand) then
	@ helper_rand = `$gtm_exe/mumps -run rand 100 1 1`
endif
echo "setenv helper_rand $helper_rand" >>! settings.csh
if ($helper_rand > 50) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP  replicate -receive -start -helpers >& helpers_start.out"
endif
#
echo "GTM Process starts in background..."
setenv gtm_test_jobcnt 5
setenv gtm_test_dbfill "IMPTP"
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep $test_sleep_sec_short
#
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/var_tp_rest.csh >>&! var_tp_rest.out"
echo "Now GTM process will end."
$gtm_tst/com/endtp.csh
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
