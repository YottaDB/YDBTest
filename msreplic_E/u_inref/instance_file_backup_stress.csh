#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
cat << EOF
# Stress test for backup of instance files. Take 10 backups on the secondary as
# primary is going on with updates. Then attempt to use them on the secondary
# and see that the connection is established to the primary.
EOF

if (! $?gtm_test_replay) then
	set randsleep = `$gtm_exe/mumps -run rand 30 10 5`	# 10 numbers in the range [5,35)
	set randshut  = `$gtm_exe/mumps -run rand 10 10`	# 10 numbers in the range [0,10)
	set randcrash = `$gtm_exe/mumps -run rand 2 10`		# 10 numbers in the range [0,2)
	echo 'setenv st_randsleep "'$randsleep'"'	>>&! settings.csh
	echo 'setenv st_randshut  "'$randshut'"'	>>&! settings.csh
	echo 'setenv st_randcrash "'$randcrash'"'	>>&! settings.csh
else
	# The below is done to convert st_rand* to array
	set randsleep = ($st_randsleep)
	set randshut =  ($st_randshut)
	set randcrash = ($st_randcrash)
endif
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh . 3 125 1000 4096 100 4096 100
echo "#- some common data on INST1 and INST2"
$MSR START INST1 INST2
setenv gtm_test_tptype "ONLINE"
setenv gtm_test_tp "TP"
setenv gtm_process  30
setenv tst_buffsize 33000000
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
set echo; sleep 30; unset echo
$gtm_tst/com/endtp.csh >>&! imptp.out
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2

$echoline
echo "#- On the primary, start the update loop"
($gtm_tst/$tst/u_inref/imptp_loop.csh >& imptp_loop.out &) >& imptp_loop_bg.out
echo "#- On the receiver INST2, do backups in the meantime:"
# since imptp_loop.csh is using $MSR, we cannot use $MSR here since it cannot handle multiple threads
set cntx = 1
$MSR STARTRCV INST1 INST2
# prepare $pri_shell and $sec_shell using a dummy $MSR call
$MSR RUN SRC=INST1 RCV=INST2 'echo secondary ready'
touch go.txt
echo "GTM_TEST_DEBUGINFO "`date`

set backupcount = 10
while ($cntx <= $backupcount)
	$echoline
	echo "# backup iteration $cntx"
	echo "# backup iteration $cntx"				>>&! backup_loop.out
	echo "# before sleep $randsleep[$cntx] : `date`"	>>&! backup_loop.out
	sleep $randsleep[$cntx]
	echo "# after sleep $randsleep[$cntx] : `date`"		>>&! backup_loop.out
	if ($randshut[$cntx] < 2) then
		# shutdown receiver
		set shut_time = `date +%H_%M_%S`_$cntx
		$sec_shell "$sec_getenv; cd $SEC_DIR; $gtm_tst/com/RCVR_SHUT.csh on < /dev/null "">>&"" $SEC_DIR/SHUT_${shut_time}.out"
		echo "round $cntx did shutdown rand=$randshut[$cntx] (logs in SHUT_${shut_time}.out)"	>>&! backup_loop.out
	else
		echo "round $cntx did not shutdown rand=$randshut[$cntx]"				>>&! backup_loop.out
	endif
	$sec_shell "$sec_getenv; cd $SEC_DIR; set bakdircntx = bakdir$cntx;"'mkdir $bakdircntx; $MUPIP backup -replinstance=$bakdircntx "*" $bakdircntx >& backup'"$cntx.log"
	if ($randshut[$cntx] < 2) then
		# bring the receiver back up again
		set portno = `$sec_shell  "$sec_getenv; cd $SEC_DIR; cat portno"`
		set start_time = `date +%H_%M_%S`_$cntx
		$sec_shell  "$sec_getenv; cd $SEC_DIR; $gtm_tst/com/RCVR.csh on $portno $start_time < /dev/null "">&!"" $SEC_DIR/START_${start_time}.out"
	endif
	@ cntx = $cntx + 1
end
echo "GTM_TEST_DEBUGINFO at the end : `date`"
echo "GTM_TEST_DEBUGINFO at the end : `date`"		>>&! backup_loop.out

$echoline
echo "# Backups complete on INST2, signal the updates to stop:"
touch end_imptp_loop.txt
$gtm_tst/com/wait_for_log.csh -log imptp_loop.done -waitcreation -duration 480
# We've brought up and shutdown the links explicitly, let's fix up the link information
$MSR REFRESHLINK INST1 INST2

$echoline
echo "#- Test all backups (10 to 1):"
set cntx = $backupcount
set suppl_parm = ""
if (0 != $test_replic_suppl_type) set suppl_parm = " -supplementary"
while ($cntx)
	$echoline
	echo "# restore iteration count $cntx"
	echo "# `date` : restore iteration count $cntx"	>>&! restore_loop.out
	echo "GTM_TEST_DEBUGINFO "`date`
	if ($randcrash[$cntx]) then
		#crash
		$MSR CRASH INST2			>>&! restore_loop.out
	else
		#shutdown
		$MSR STOPRCV INST1 INST2		>>&! restore_loop.out
	endif
	#for debugging:
  	$MSR RUN INST2 '$gtm_tst/com/backup_dbjnl.csh cpdir'$cntx' "*.dat *.gld *.mjl* *.repl"'
	set bakdircntx = bakdir$cntx
	echo "#- Revert to bakdircntx ($bakdircntx) contents, and cut new journal files (not traced below)"
	# do not trace the below run because, test_remote_jnldir of -multisite is not handled by the framework
	$MSR RUN INST2 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 ; cp -p $bakdircntx/* .; $gtm_tst/com/jnl_on.csh $test_remote_jnldir ; mv mumps.repl sec_${cntx}_mumps.repl"
	#$MSR RUN INST2 "mv mumps.repl sec_${cntx}_mumps.repl"
	$MSR RUN INST2 'set msr_dont_trace ; $MUPIP replic -instance_create '$suppl_parm' '$gtm_test_qdbrundown_parms' -name=__SRC_INSTNAME__'
	$MSR STARTRCV INST1 INST2 waitforconnect updateresync=sec_${cntx}_mumps.repl
  	echo "# - check that the connection is alive by doing a checkhealth and checking the backlog reduces"
	$gtm_tst/com/is_src_backlog_below.csh 0
	set backlog = $status
	echo "# `date` : backlog value returned is: $backlog"					>>&! restore_loop.out
	$MSR RUN SRC=INST1 RCV=INST2 "$gtm_tst/com/wait_until_src_backlog_below.csh $backlog"	>>&! restore_loop.out
	@ cntx = $cntx - 1
end

$echoline
echo "GTM_TEST_DEBUGINFO "`date`
echo "#- Wrap-up"
$MSR SYNC INST1 INST2
echo "#	--> We expect it to sync correctly."
# INST3 receiver server was never "officially" started in the test. So, there isn't any mumps.repl file available in INST3. If
# $gtm_custom_errors is set, then the INTEG on INST3 will error out with FTOKERR/ENO2. To avoid this, unsetenv gtm_custom_errors.
unsetenv gtm_custom_errors
# For multihost tests, setting it in the environment is not enough. So, create unsetenv_individual.csh and send it to INST3 which gets sourced by remote_getenv.csh.
echo "unsetenv gtm_custom_errors" >&! unsetenv_individual.csh
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/unsetenv_individual.csh _REMOTEINFO___RCV_DIR__/'	 >&! transfer_unsetenv_individual.out
$gtm_tst/com/dbcheck.csh -extract INST1 INST2
