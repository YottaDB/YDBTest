#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# receiver server / update process fail/crash/stop and restart test cases
# Case 0 : receiver fail
# Case 1 : receiver stop
# Case 2 : updproc fail
# Case 3 : receiver crash
if !($?gtm_test_replay) then
	set cases = 4	 # case 0 thru case 3
	set crash_case = `$gtm_exe/mumps -run rand $cases`
	echo "# Randomly chosen stop/fail/crash option : $crash_case"	>>&! settings.csh
	echo "setenv stopfailcrash_todo $crash_case"			>>&! settings.csh
	setenv stopfailcrash_todo $crash_case
endif
if ( 3 == "$stopfailcrash_todo" ) then
	setenv gtm_test_crash 1
	# If nobefore-image journaling is in use, we can only use forward rollback (no backward rollback possible).
	# If before-image journaling is in use, we can use either. If backward rollback is chosen, a hidden forward rollback
	#	is also attempted as part of mupip_rollback.csh. If forward_only is chosen randomly, only a forward rollback
	#	is attempted in this case.
	if ($gtm_test_jnl_nobefore) then
		set forw_only = "forward_only"
	else
		if !($?gtm_test_replay) then
			set rand = `$gtm_exe/mumps -run rand 2`
			echo "# Randomly chosen forw_only option : $rand"	>>&! settings.csh
			echo "setenv stopfailcrash_todo_3_forw_only $rand"	>>&! settings.csh
		else
			set rand = $stopfailcrash_todo_3_forw_only
		endif
		if ($rand) then
			set forw_only = "forward_only"
		else
			set forw_only = ""
		endif
	endif
	if (("" != $forw_only) && (! $gtm_test_forward_rollback)) then
		# We need to use forward rollback in the test but the test framework set gtm_test_forward_rollback to 0.
		# Set the env var to 1.
		echo "# Test forced below setting due to choice of forward rollback"	>> settings.csh
		echo "setenv gtm_test_forward_rollback 1"				 >> settings.csh
		setenv gtm_test_forward_rollback 1
	endif
endif
# Since the receiver is explicitly restarted without -tlsid, the source server (if started with -tlsid) would error out with
# REPLNOTLS. To avoid that, allow for the source server to fallback to plaintext when that happens.
setenv gtm_test_plaintext_fallback
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "# GTM Processes starts..."
$gtm_tst/com/imptp.csh >>&! imptp.out
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

echo "# Crash/Stop/Fail receiver..."
$gtm_tst/com/rfstatus.csh "BEFORE_RCVR_DOWN"
if ( 0 == "$stopfailcrash_todo" ) then
	$sec_shell "$sec_getenv; $gtm_tst/$tst/u_inref/receiver_fail.csh >&! receiver_fail.out"
else if ( 1 == "$stopfailcrash_todo" ) then
	$sec_shell "$sec_getenv; $gtm_tst/$tst/u_inref/receiver_stop.csh >&! receiver_stop.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE ; mv RCVR_${start_time}.log RCVR_${start_time}.logx ; $grep -v YDB-F-FORCEDHALT RCVR_${start_time}.logx >&! RCVR_${start_time}.log"
else if ( 2 == "$stopfailcrash_todo" ) then
	$sec_shell "$sec_getenv; $gtm_tst/$tst/u_inref/updproc_fail.csh >&! updproc_fail.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE ; mv RCVR_${start_time}.log.updproc RCVR_${start_time}.log.updprocx ; $grep -v YDB-F-FORCEDHALT RCVR_${start_time}.log.updprocx >&! RCVR_${start_time}.log.updproc"
else
	$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh >&! receiver_crash.out"
endif

# Manually unfreeze just in case a process set the freeze right before getting killed. We don't do this for case 3 because receiver_crash.csh removes journal pool.
if (3 != "$stopfailcrash_todo") then
    $sec_shell "$sec_getenv; cd $SEC_SIDE ; "'$MUPIP'" replicate -source -freeze=off"
endif

echo "# GTM processes run to create backlog..."
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

setenv start_time `date +%H_%M_%S`
setenv tst_buffsize 33554432
setenv RCVR_LOG_FILE $SEC_SIDE/RCVR_${start_time}.log
setenv LOG_UPDATES $tst_general_dir/tmp/UPDPROC_${start_time}.log
if ( 3 == "$stopfailcrash_todo" ) then
	if ("" != "$forw_only") then
		# Take backup of instance file on primary (needed for -updateresync startup of RCVR on secondary after forward rollback)
		# test framework uses the name srcinstback.repl so use a different name.
		# The below 6 lines are copied from SRC.csh
		$MUPIP backup -replinstance=srcinstback2.repl >& backup.log
		if ($tst_now_primary != $tst_now_secondary) then
			$rcp srcinstback2.repl "$tst_now_secondary":"$SEC_SIDE"
		else
			cp srcinstback2.repl $SEC_SIDE
		endif
	endif
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1"	# debug
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/mupip_rollback.csh $forw_only"' -losttrans=lost1.glo "*" >&! rollback1.log; if ($status) echo "rollback failed"'
endif
echo "# Restart receiver..."
if ( 3 == "$stopfailcrash_todo" ) then
	if ("" != "$forw_only") then
		setenv updrsyncquals "updateresync=srcinstback2.repl"
		if (1 == $test_replic_suppl_type) then
			setenv updrsyncquals "$updrsyncquals -resume=1"
		endif
	else
		setenv updrsyncquals ""
	endif
	$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "on" $portno $start_time $updrsyncquals < /dev/null >>&! START_${start_time}.out'
else if ( 2 == "$stopfailcrash_todo" ) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replicate -receiver -start -updateonly >>&! restart_updateproc.out'
else
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replic -receiv -start -buffsize=$tst_buffsize -listen=$portno -log=$RCVR_LOG_FILE </dev/null '
endif

$gtm_tst/com/rfstatus.csh "RECEIVER_UP:"
echo "# GTM process continues..."
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec_short "" noerror
echo "# Stop GTM processes in primary..."
$gtm_tst/com/endtp.csh >>& endtp.out
if ( (2 == "$stopfailcrash_todo") || (3 == "$stopfailcrash_todo") ) then
	$gtm_tst/com/dbcheck_filter.csh -extract
else
	$gtm_tst/com/dbcheck.csh -extract
endif
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
