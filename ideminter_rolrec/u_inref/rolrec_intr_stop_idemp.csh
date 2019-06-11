#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# called as: rolrec_intr_stop_idemp.csh [ROLLBACK|RECOVER] [CRASH|STOP|IDEMP] [GTM_CRASH|GTM_SHUTDOWN|.] [ZTP] [round no]
# The third argument is just for debugging, to eliminate randomness in the stopping of the GT.M updates
# If there is no third argument (or if it is .), it will be random
#Test case # 63 and # 64
unset backslash_quote
set test_rol_or_rec = $1
set crash_stop_idemp = $2
set test_ztp = $4
set test_fivemin_epoch = 0
if (("RECOVER" == $test_rol_or_rec) && ("CRASH" == $crash_stop_idemp)) set test_fivemin_epoch = 1
if ("ROLLBACK" == "$test_rol_or_rec") setenv gtm_repl_instance mumps.repl
echo "# Random RECOVER/ROLLBACK choice is : GTM_TEST_DEBUGINFO $test_rol_or_rec"
echo '# substitute mentions of $test_rol_or_rec in reference file with the above'
set round_no = 1
if ("" != $5) set round_no = $5
if (1 != $round_no) set test_fivemin_epoch = 0
set usedblockver = "" 			# check to see if the prior round used V4 blocks
setenv gtm_test_onlinerollback "FALSE"  # Default to -noonline rollback
setenv rollbackmethod ""
unsetenv test_replic
if ("CRASH" == "$crash_stop_idemp") then
	# This whitebox test case serves two purpose.
	#
	# 1. This test does kill -9 followed by a MUPIP JOURNAL -RECOVER. A kill -9 could hit the running GT.M process while it		#BYPASSOK("kill")
	# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
	# memory. So, set the white box test case to avoid asserts in wcs_flu.c
	#
	# 2. Since we do interrupted recovery and rollback, it is possible, in some rare cases for TP resolve time to be adjusted by
	# a significant amount. This will cause asserts in mur_back_process.c to fail. To avoid that, set the following whitebox
	# test case.
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 29
endif
if ($?gtm_white_box_test_case_number) then
	echo "# $crash_stop_idemp forces the following whitebox test case"				>> settings.csh
	echo "setenv gtm_white_box_test_case_enable $gtm_white_box_test_case_enable"			>> settings.csh
	echo "setenv gtm_white_box_test_case_number $gtm_white_box_test_case_number"			>> settings.csh
endif

if ($?gtm_test_replay) then
	echo "TEST-I-JNL_REPLAY will be replaying $gtm_test_replay"					>>! replay.log
	if (! -e $gtm_test_replay) then
		echo "TEST-E-JNL_REPLAYFILE the gtm_test_replay file cannot be found ("'$gtm_test_replay:' "$gtm_test_replay"
		echo "Will not continue."
		exit 1
	endif
	source $gtm_test_replay
else
	# not replay, choose randomly
	echo "# $round_no ##############################################"				>> settings.csh
	set crash_updates = 0
	set rand = `$gtm_exe/mumps -run rand 10`
	if (6 < $rand) set crash_updates = 1
	echo "# randomly chosen option to crash updates"						>> settings.csh
	echo "# 0 - 30% of the time, cleanly shut down the processes"					>> settings.csh
	echo "# 1 - 70% of the time, SIGKILL the processes"						>> settings.csh
	echo "set crash_updates = $crash_updates"							>> settings.csh
	# This test does kill -9 of mumps/mupip processes. A kill -9 could hit the running process while it
	# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
	# memory. So, set the white box test case to avoid asserts in wcs_flu.c when a later mumps/mupip process comes to flush.
	if (1 == $crash_updates) then
		# When crashing GT.M
		setenv gtm_white_box_test_case_enable 1
		setenv gtm_white_box_test_case_number 29
		echo "# Random choice crash_updates == 1 forces the following whitebox test case"	>> settings.csh
		echo "setenv gtm_white_box_test_case_enable $gtm_white_box_test_case_enable"		>> settings.csh
		echo "setenv gtm_white_box_test_case_number $gtm_white_box_test_case_number"		>> settings.csh
	endif
	if ("ROLLBACK" == "$test_rol_or_rec") then
		set usedblockver = `$gtm_tst/com/check_for_V4_blocks.csh`
		if (("STOP" == "$crash_stop_idemp") || ("V4" == "$usedblockver")) then
			# - Online Rollback cannot be MUPIP STOPped after it starts. Skip the STOP test as it
			#   expects to succeed in stopping MUPIP in the middle of a ROLLBACK
			# - interrupted_rollback calls this script twice, if the prior round used V4 blocks,
			#   avoid using Online Rollback
			setenv gtm_test_onlinerollback "FALSE"
		else
			setenv gtm_test_onlinerollback "`$gtm_exe/mumps -run chooseamong TRUE FALSE`"
		endif
		echo "# randomly chosen Online Rollback status"						>> settings.csh
		echo "setenv gtm_test_onlinerollback $gtm_test_onlinerollback"				>> settings.csh
		if ("TRUE" == "$gtm_test_onlinerollback") then
			setenv gtm_test_mupip_set_version "V5" # online rollback is incompatible with V4 blocks
			echo "setenv gtm_test_mupip_set_version $gtm_test_mupip_set_version"		>> settings.csh
			setenv rollbackmethod "-online"

		else
			setenv rollbackmethod "`$gtm_exe/mumps -run chooseamong "" -noonline`"
		endif
		echo "# randomly chosen rollback method"						>> settings.csh
		echo "setenv rollbackmethod '$rollbackmethod'"						>> settings.csh
	endif
endif
if (1 == $round_no) then
	$gtm_tst/com/dbcreate.csh mumps 8 125-1019 400-1024 ${tst_rand_blksize} -alloc=5000
endif

if (! -d $gtm_test_log_dir) then
	mkdir -p $gtm_test_log_dir
	if ($status) then
		echo "TEST-E-LOGDIR, cannot create log directory $gtm_test_log_dir for test $tst. Will not be able to save logs"
	else
		chmod 775 $gtm_test_log_dir
	endif
endif

setenv tst_jnl_str_save "$tst_jnl_str"
setenv tst_jnl_str "-journal=enable,on,before"
# At this point, replication instance file (mumps.repl) is not yet created and if $gtm_custom_errors is defined, then the below
# jnl_on_ind.csh script or the MUPIP SET operations below will error out with FTOKERR/ENO2 errors due to the non-existence of the
# mumps.repl file. To avoid that unsetenv gtm_repl_instance temporarily.
unsetenv gtm_repl_instance
if (1 == $round_no) then
	echo "Turn Journaling on (check jnl_on.log for the actual settings)..."
	$gtm_tst/$tst/u_inref/jnl_on_ind.csh $test_fivemin_epoch >&! jnl_on.log
else
	echo "Switch journal files for some regions..."
	$MUPIP set ${tst_jnl_str},epoch=150 -file b.dat >>& round2_jnl.log
	$MUPIP set ${tst_jnl_str},epoch=150 -file d.dat >>& round2_jnl.log
	$MUPIP set ${tst_jnl_str},epoch=140 -file f.dat >>& round2_jnl.log
	$MUPIP set ${tst_jnl_str},epoch=140 -file g.dat >>& round2_jnl.log
	if ("RECOVER" == $test_rol_or_rec) then
		# Test that they do not autoswitch with the next update...
		set count1 = `ls *.mjl* | wc -l`
		ls *.mjl* > ls1.out
		$gtm_exe/mumps -run %XCMD 'set (^b,^d,^f,^g)=1'
		set count2 = `ls *.mjl* | wc -l`
		ls *.mjl* > ls2.out
		if ($count1 != $count2) echo "TEST-E-AUTOSWITCH, an unexpected autoswitch occurred. Check ls*.out"
	endif
endif
if ($status) then
	echo "TEST-E-JNL_ON, error from jnl_on_ind, check jnl_on.log"
	exit
endif
$grep '.-E-' jnl_on.log >& /dev/null
if (! $status) then
	echo "TEST-E-JNL error turning Journaling on. Will not continue. Check jnl_on.log"
	exit
endif
echo "Start the Source Server if ROLLBACK..."
if ("ROLLBACK" == "$test_rol_or_rec") then
	#ROLLBACK
	setenv gtm_repl_instance mumps.repl # Only rollback needs the instance file
	$gtm_tst/com/passive_start_upd_enable.csh >& START_`date +%H_%M_%S`.log
	if ("IDEMP" == $crash_stop_idemp) then
		$gtm_tst/com/backup_for_mupip_rollback.csh # needed because this test does not turn on replication using dbcreate
	endif
	# else for CRASH or STOP we cannot use forward rollback (due to interrupted rollback) so dont even bother taking a backup
endif
if ($LFE == "L") then
	setenv gtm_update_time 30
else
	setenv gtm_update_time 150
	# longer for 5 min epoch
	if ($test_fivemin_epoch) setenv gtm_update_time 300
	if (1 != $round_no) setenv gtm_update_time 100
endif

$gtm_tst/com/abs_time.csh time1 | sed 's/: /:GTM_TEST_DEBUGINFO/'
set time1 = `cat time1_abs`
setenv gtm_test_jobcnt 5
# gtm_test_crash should be set before imptp is called
setenv gtm_test_crash $crash_updates
setenv gtm_test_noisolation TPNOISO
echo "setenv test_noisolation TPNOISO" >> settings.csh
setenv gtm_test_dbfill "IMPTP"
echo "Start GT.M updates..."
$gtm_tst/com/imptp.csh >&! imptp.out
# ONLINE_ROLLBACK is not compatible with V4 block format. Disable the upgrade/downgrade
if ("TRUE" != "$gtm_test_onlinerollback") then
	echo "GTM_TEST_DEBUGINFO Start MUPIP upgrade/downgrade/set version=V4/set version=V5..."
	# The bkgrnd_reorg_upgrd_dwngrd script randomly decides to do a MUPIP SET -VERSION command. If $gtm_custom_errors is defined
	# the MUPIP SET command will try to open the journal pool if one exists. But, the journal pool's existence is shuffled by
	# the repeated passive source server startup and shutdown commands issued by the wait_multiple_history.csh script below.
	# If the timing is right, it is possible that the passive source server opens the journal pool but doesn't yet open the
	# database. At this point, if the reorg command opens the journal pool (in gvcst_init) and then opens the database only to
	# find that the database is not bound to the journal pool (since the source server hasn't yet filled in csa->nl fields
	# corresponding to instfilename and jnlpool_shmid), REPLINSTMISMTCH error will be issued. To avoid this, unsetenv repl
	# instance so that MUPIP SET commands don't open journal pool.
	unsetenv gtm_repl_instance
	$gtm_tst/com/bkgrnd_reorg_upgrd_dwngrd.csh >>&! bkgrnd_reorg_upgrd_dwngrd.out
	if ("ROLLBACK" == "$test_rol_or_rec") then
		setenv gtm_repl_instance mumps.repl
	endif
else
	echo "GTM_TEST_DEBUGINFO Online Rollback testing, will not start MUPIP upgrade/downgrade/set version=V4/set version=V5..."
endif
echo "# gtm_update_time = GTM_TEST_DEBUGINFO $gtm_update_time"
echo 'Wait for $gtm_update_time seconds (might switch some journal files explicitly in the meantime. Check halftime.txt)...'
@ halftime = $gtm_update_time / 2
$gtm_tst/$tst/u_inref/wait_multiple_history.csh $halftime $test_rol_or_rec >& sleep1.out
set rand = `$gtm_exe/mumps -run rand 2`
if (0 == $rand) then
	# 50% of the time, switch two region's journal files.
	echo "Switching journal files for b.dat and e.dat" >>! halftime.txt
	$MUPIP set $tst_jnl_str -file b.dat >>&! halftime.txt
	$MUPIP set $tst_jnl_str -file e.dat >>&! halftime.txt
endif
$gtm_tst/$tst/u_inref/wait_multiple_history.csh $halftime $test_rol_or_rec >& sleep2.out
if (ROLLBACK == $test_rol_or_rec) then
	#ROLLBACK
	$MUPIP replicate -source -showbacklog >>& showbacklog.log
	setenv max_seqno `$tst_awk '/sequence number of last transaction written to journal pool/{print $1}' showbacklog.log`
	echo $max_seqno >! max_seqno.txt
endif

$gtm_tst/com/abs_time.csh time2 |& sed 's/: /:GTM_TEST_DEBUGINFO/'
set time2 = `cat time2_abs`

if (1 != $round_no) then
	# in the second round, take the time1 (initial time) of round 1 as time1 again
	mv time1  time1_round1
	mv time1_abs time1_abs_round1
	cp round1/time1* .
	set time1 = `cat time1_abs`
endif
echo "Stop the updates either with endtp (shutdown.out) or crash (crash.out) (30%-70%). Check which one of crash.out or shutdown.out exists."
echo "set crash_updates = $crash_updates " >>! jnl_settings.txt

if (! $crash_updates) then
	echo "GT.M will be shutdown nicely" 			>>& shutdown.out
	date							>>& shutdown.out
	$gtm_tst/com/endtp.csh					>>& shutdown.out
	date							>>& shutdown.out
	if ("TRUE" != "$gtm_test_onlinerollback") then
		# online rollback does not support V4 blocks, upgrade/downgrade was not started
		$gtm_tst/com/close_reorg_upgrd_dwngrd.csh	>>& close_reorg_upgrd_dwngrd.out
		date						>>& shutdown.out
	endif
	if (ROLLBACK == $test_rol_or_rec) then
		#ROLLBACK
		$MUPIP  replic -source -shutdown -timeout=0	>& SHUT_`date +%H_%M_%S`.log
	endif
else
	echo "CRASH GT.M"					>>& crash.out
	# first crash the bkgrnd_reorg_upgrd_dwngrd.csh processes, but do not remove ipcs since the other crash scripts will do that
	date							>>& crash.out
	if ("TRUE" != "$gtm_test_onlinerollback") then
		# online rollback does not support V4 blocks, upgrade/downgrade was not started
		$gtm_tst/com/mu_reorg_upgrd_dwngrd_crash.csh	>>& crash.out
		date						>>& crash.out
	endif
	set do_corrupt = "TRUE"
	if (RECOVER == $test_rol_or_rec) then
		#RECOVER
		$gtm_tst/com/gtm_crash.csh			>>& crash.out
		date						>>& crash.out
	else
		#ROLLBACK
		date						>>& crash.out
		setenv PRI_SIDE `pwd`
		if ("TRUE" != "$gtm_test_onlinerollback") then
			$gtm_tst/com/primary_crash.csh		>>& crash.out
		else
			# online rollback does not remove IPCS
			$gtm_tst/com/primary_crash.csh "NO_IPCRM" >>& crash.out
			# Since we do not remove IPCs, the tail of the journal file should not be corrupted. This is necessary as
			# otherwise when online rollback flushes journal buffers to disk, it can end up over-writing some of the
			# corruption and can cause the database to be ahead of the journal files (as far as the tail of the journal
			# file is concerned). See <C9I12003062_interrupted_rollback_DBTNTOOLG_tail_corruption> for more details.
			set do_corrupt = "FALSE"
		endif
	endif
	if ("TRUE" == "$do_corrupt") then
		$gtm_tst/com/corrupt_jnlrec.csh a c mumps	>>& corrupt_jnlrec.log
	endif

endif

echo "##########################################"
echo 'Testing MUPIP ${test_rol_or_rec}...'		# Single quote to not expand $test_rol_or_rec
echo 'Check the output at MUPIP_${test_rol_or_rec}.log'
$gtm_tst/$tst/u_inref/rolrec_three_tries.csh $test_rol_or_rec $crash_stop_idemp $test_ztp $round_no >&! MUPIP_${test_rol_or_rec}.log
set stat = $status
$head -n 1 ${test_rol_or_rec}${round_no}_?.log
if (4 == $stat) then
	echo "TEST-E-FAIL, TEST FAILED"
	# The script runs ONLINE REORG UPGRADE/DOWNGRADE in the background. When the below dbcheck is called, it is
	# possible that the database has V4 format blocks. In such a case, if gtm_test_online_integ is randomly chosen
	# to be "-online" then ONLINE INTEG will issue SSV4NOALLOW error. Hence, instruct dbcheck to do a NOONLINE INTEG
	# irrespective of what the value of gtm_test_online_integ is.
	# Since this test has exited prematurely, do not generate .sprgde file too.
	$gtm_tst/com/dbcheck_filter.csh -noonline -nosprgde
	exit 1
endif
if ("RECOVER" == ${test_rol_or_rec}) then
	$grep "The time of the" MUPIP_${test_rol_or_rec}.log 		>>&! times_seqnos_used.txt
	$grep -E "since_time|before_time" MUPIP_${test_rol_or_rec}.log	>>&! times_seqnos_used.txt
else
	$grep -E "^max_seqno is:|^seqno:" MUPIP_${test_rol_or_rec}.log	>>&! times_seqnos_used.txt
endif
echo "# The times (if RECOVER) or seqnos (if ROLLBACK) are logged in times_seqnos_used.txt"
echo "##########################################"
echo 'And one complete ${test_rol_or_rec}:'
setenv logno "_last_${round_no}"
set bakdir = "bak_${test_rol_or_rec}${logno}"
$gtm_tst/com/backup_dbjnl.csh $bakdir '*.dat *gld *.mjl* *.repl*'
# run MUPIP with -noverify half the time
set verify = "-verify"
set rand = `$gtm_exe/mumps -run rand 2`
if (0 == $rand) set verify = "-noverify"
echo "Using $verify" >&! verify${logno}.log

if (RECOVER == $test_rol_or_rec) then
	#RECOVER
	set since_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .25`
	mv timecalc.txt since_time${logno}.txt
	set before_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .75`
	mv timecalc.txt before_time${logno}.txt
	# to specify delta-time
	set before = `date +%s`
	set specifytime = `$gtm_exe/mumps -run rand  2`
	echo "# The decision to specify is : GTM_TEST_DEBUGINFO $specifytime"
	if ($specifytime) then
		alias command  '$MUPIP journal -recover -back "*" -since=\"'$since_time'\" -before=\"'$before_time'\"' $verify -verbose
	else
		alias command  '$MUPIP journal -recover -back "*" ' $verify -verbose
		echo "0" >! since_time${logno}.txt
		echo "0" >! before_time${logno}.txt
	endif
	alias command >&! ${test_rol_or_rec}_last.log
	command >>&! ${test_rol_or_rec}_last.log
	set after = `date +%s`
else
	#ROLLBACK
	set before = `date +%s`
	# take a percentage of it (not to be less than 1)
	# seqno: [0-100] % of max_seqno
	@ rand = `$gtm_exe/mumps -run rand 100`
	# Compute seqno but set it to a minimum of 25 to keep checkdb.m happy
	setenv seqno `echo $max_seqno $rand | $tst_awk '{x=$1*$2/100; if (x < 25) x=25; printf "%d",x;}'`
	# for debugging:
	echo "$rand $seqno (max: $max_seqno)" >>! max_seqno${logno}.txt
	echo $seqno >! seqno${logno}.txt
	# TODO online rollback is busted, cannot use -resync in the last run : see MREP interrupted_rollback_DBFGTBC_DBTOTBLK_incomplete_extension
	if ("TRUE" != "$gtm_test_onlinerollback") then
		set specifyresync = `$gtm_exe/mumps -run rand  2`
	else
		set specifyresync = 0
	endif
	echo "# The decision to specify is : GTM_TEST_DEBUGINFO $specifyresync"
	if ($?gtm_test_freeze_on_error) then
		if ($gtm_test_freeze_on_error) then
			# We may have hit DBDANGER or some other custom error, so unfreeze before the final rollback.
			$MUPIP replic -source -freeze=off >&! unfreeze${logno}.outx
		endif
	endif
	# Can go through mupip_rollback.csh (which will also test forward rollback) only in case of uninterrupted rollbacks
	# Use regular rollback otherwise.
	if ("IDEMP" == $crash_stop_idemp) then
		set cmd = "$gtm_tst/com/mupip_rollback.csh"
	else
		set cmd = "$MUPIP journal -rollback -backward"		# BYPASSOK("-rollback")
	endif
	if ($specifyresync) then
		alias command ''$cmd' '$rollbackmethod' -resync='$seqno' -lost=ROLLBACK_last.lost '$verify' "*"' -verbose
	else
		alias command ''$cmd' '$rollbackmethod'                  -lost=ROLLBACK_last.lost '$verify' "*"' -verbose
		echo 0 >! seqno${logno}.txt
		mv max_seqno.txt max_seqno_real${logno}.txt
		echo 0 >! max_seqno.txt
	endif
	alias command >&! ${test_rol_or_rec}_last.logx
	command >>&! ${test_rol_or_rec}_last.logx
	# Online Rollback can result in an erroneous MUKILLIP. Regular rollback should not
	if ("${rollbackmethod}" == "-online" ) then
		$grep -v MUKILLIP ${test_rol_or_rec}_last.logx >&! ${test_rol_or_rec}_last.log
	else
		mv ${test_rol_or_rec}_last.logx ${test_rol_or_rec}_last.log
	endif
	set after = `date +%s`
endif
echo 'Check ${test_rol_or_rec}_last.log'
$head -n 1 ${test_rol_or_rec}_last.log
# since we do not verify everytime, we need to filter that line out as well as the info messages
#$grep -v '.-I-' ${test_rol_or_rec}_last.log | grep -v Verify
# we need to filter out show output for the (possibly) broken transactions)
$grep -E ".-[ES]-" ${test_rol_or_rec}_last.log | $grep -v "Verify successful" | $grep -vi "$test_rol_or_rec successful"
@ difftime = $after - $before
echo "The time the mupip command took: " $difftime
source $gtm_tst/$tst/u_inref/find_span.csh $crash_stop_idemp
set rol_or_rec_log="$gtm_test_log_dir/${HOST:r:r:r}_${test_rol_or_rec}.log"
echo "MUPIP ${test_rol_or_rec} ${2} ${test_ztp} LAST: $difftime $span ($tst_general_dir)" | tee -a ${HOST:r:r:r}_${test_rol_or_rec}.log >>&! $rol_or_rec_log
#Change permissions to group writable
chmod 664 $rol_or_rec_log >& /dev/null
echo "##########################################"

echo "Checking..."
$gtm_tst/com/abs_time.csh time3 |& sed 's/: /:GTM_TEST_DEBUGINFO/'
# The script runs ONLINE REORG UPGRADE/DOWNGRADE in the background. When the below dbcheck is called, it is possible that
# the database has V4 format blocks. In such a case, if gtm_test_online_integ is randomly chosen to be "-online" then
# ONLINE INTEG will issue SSV4NOALLOW error. Hence, instruct dbcheck to do a NOONLINE INTEG irrespective of what the
# value of gtm_test_online_integ is.
# If the first round only then do dbcheck with -sprgde. For second rounds we dont do dbcreate in this script so dont do
# dbcheck with -sprgde (or else we would get a TEST-E-SPRGDEEXISTS error.
if (1 == $round_no) then
	$gtm_tst/com/dbcheck_filter.csh -noonline
else
	$gtm_tst/com/dbcheck_filter.csh -noonline -nosprgde
endif
$gtm_tst/com/abs_time.csh time4 |& sed 's/: /:GTM_TEST_DEBUGINFO/'
#
# We have random since_time/sequence number for recover/rollback. This take database to an arbitrary point.
# That is, a particular iteration of imptp/impztp may not be complete. checkdb needs to handle that.
# So, we do setenv gtm_test_crash 1 before checkdb.
setenv gtm_test_crash 1
$gtm_tst/com/checkdb.csh
#
$gtm_tst/com/abs_time.csh time5 |& sed 's/: /:GTM_TEST_DEBUGINFO/'
# check the journal files
echo "Verify journal files..."
foreach mjlfile (?.mjl* mumps.mjl*) # do not check the rolled_bak* files
	echo "Verifiying file ${mjlfile}:"  >>&! verify.log
	(set echo; $MUPIP journal -verify -forward $mjlfile) >>&! verify.log
end
$gtm_tst/com/abs_time.csh time6 |& sed 's/: /:GTM_TEST_DEBUGINFO/'
setenv tst_jnl_str "$tst_jnl_str_save"

if ("CRASH" != "$crash_stop_idemp") then
	# In case of "STOP" (i.e. MUPIP STOP) or "IDEMP" (no crash), we dont expect any leftover
	# temporary extract files, shmids etc (created in case gtm_mupjnl_parallel != 1).
	$gtm_tst/com/mupjnl_check_leftover_files.csh
endif
