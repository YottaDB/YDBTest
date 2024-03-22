#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

#
# TEST : LOST TRANSACTION TESTING (6.24)
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # this test does a failover and so disable -trigupdate

# This test does a controlled fail over. A->P won't work in this case. Re-randomize, ignoring A->P
source $gtm_tst/com/rand_suppl_type.csh 0 2
# For this test buffer size is 1 MB and  5 processes
setenv gtm_test_tptype "ONLINE"
setenv test_debug 1
setenv tst_buffsize  1048576
set gtm_process = 5
# enable noisolation
setenv gtm_test_noisolation TPNOISO
#
# Randomize
if (! $?gtm_test_replay) then
	setenv rcvr_rand `$gtm_exe/mumps -run rand 2`
	setenv rollback_rand `$gtm_exe/mumps -run rand 2`
	echo "setenv rcvr_rand $rcvr_rand"		>>&! settings.csh
	echo "setenv rollback_rand $rollback_rand"	>>&! settings.csh
endif

if (0 == $rollback_rand) then
	setenv gtm_test_mupip_set_version "disable"	# ONLINE ROLLBACK cannot work with V4 format databases
endif

# Pass "-nostats" to dbcreate.csh to keep things in sync with the previous lines where "ydb_statshare"/"gtm_statshare"
# env var is unset. Not passing "-nostats" causes the update process to open the statsdb on the receiver side causing
# the `Current Transaction` for those statsdb files to be 1 whereas the Zqgblmod Trans is 0 resulting in a test failure.
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 -allocation=2048 -extension_count=2048 -nostats

setenv portno `$sec_shell 'cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
if ($LFE == "E") then
        setenv test_sleep_sec 30
else
	setenv test_sleep_sec 10
endif

# GTM Process starts
echo "Generate first batch of updates"
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh $gtm_process >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
echo "While updates are happening, sleep GTM_TEST_DEBUGINFO $test_sleep_sec seconds"
sleep $test_sleep_sec
$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/RF_sync.csh
$gtm_tst/com/rfstatus.csh "AFTER_Step1"
$gtm_tst/$tst/u_inref/getall_jnlseqno.csh "AFTER_Step1"
$MUPIP extract mumps1.gbl >>&! extr.log
$tail -n +3 mumps1.gbl > mumps1.glo

echo "Shut down receiver server to create backlog..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

# GTM Process starts
echo "Generate second batch of updates"
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
echo "While updates are happening, sleep GTM_TEST_DEBUGINFO $test_sleep_sec seconds"
sleep $test_sleep_sec
$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/srcstat.csh "AFTER_Step2"
$gtm_tst/$tst/u_inref/getall_jnlseqno.csh "AFTER_Step2"
$gtm_tst/com/SRC_SHUT.csh "." >>&! SHUT_${start_time}.out
#Extract globals
$MUPIP extract mumps2.gbl >>&! extr.log
$tail -n +3 mumps2.gbl > mumps2.glo

#######################
#Controlled SWITCH OVER
#######################
$DO_FAIL_OVER
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP:"" < /dev/null"

cd $PRI_SIDE
echo "Note down database transaction numbers on new primary"
$DSE all -dump >&! dbtn_list1.out
$tst_awk '/Current transaction/ {print $3}' dbtn_list1.out > db_tn.out
echo "Do some updates on new primary so db tn changes in every region"
$GTM << GTM_EOF
	; dbcreate done in this test uses 4 regions so we set 4 globals that map to each region
	; Note that with .sprgde files being randomly used, it is possible the four globals below dont map to 4 different regions
	; But that is okay. In that case we will not have changed db_tn in all regions but would have done it in at least one region.
	for i=1:1:100 set (^azTMP(i),^bzTMP(i),^czTMP(i),^dzTMP(i))=""
GTM_EOF

cd $SEC_SIDE
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.mjl* *.repl *.gld" cp
if (0 == $rcvr_rand) then
	# Start rcvr normally and expect it to fail.
	$sec_shell "$sec_getenv; cd $SEC_SIDE ; $gtm_tst/com/RCVR.csh "." $portno $start_time >&! RCVR_${start_time}.out"
	$sec_shell '$sec_getenv; cd $SEC_SIDE ; $gtm_tst/com/wait_for_log.csh -log $RCVR_LOG_FILE -message "REPLAHEAD"'
	$sec_shell '$sec_getenv; cd $SEC_SIDE ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
	### Manually shutdown the passive source server
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -source -shutdown -timeout=0" >&! passive_src_shut.out
endif

if (0 == $rollback_rand) then
	# Start rcvr with -autorollback
	$sec_shell "$sec_getenv; cd $SEC_SIDE;  setenv gtm_test_autorollback TRUE ; $gtm_tst/com/RCVR.csh "." $portno $start_time >&! RCVR_${start_time}.out"
	# With AIO turned on, we have seen the Before image applying phase of the online rollback take as much as 3 minutes
	# even on a fast system and the test failed because the max timeout was set to 3 minutes (180 seconds) below.
	# Therefore we now set the max timeout, using the `-duration` option, to 10 minutes (600 seconds).
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $RCVR_LOG_FILE -message YDB-I-ORLBKCMPLT -duration 600; if (! -e a.lost) mv *.lost a.lost"	# Rename lost transaction file (which could be a.lost or b.lost or c.lost etc.) to fixed name a.lost
else
	# Do rollback -fetchresync
	$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=$SEC_SIDE/a.lost "*"  >&! rollback.log
endif
$cprcp $SEC_SIDE/a.lost $PRI_SIDE/a.lost

#Extract globals. Remove azTMP, bzTMP etc. from comparison as they were locally applied on B and is possible did not
#yet make it to A at the time of the mupip extract.
$MUPIP extract mumps3.gbl >>&! extr.log
$tail -n +3 mumps3.gbl | $grep -v "^\^[abcd]zTMP(" > mumps3.glo
diff mumps1.glo mumps3.glo >& trans1.diff
if (-z trans1.diff) then
	echo "ROLLBACK Synchronization is OK"
else
	echo "TEST FAILED: mumps1.glo and mumps3.glo differs"
	echo "ROLLBACK DID NOT REACH CORRECT SEQNO"
endif
if (1 == $rollback_rand) then
	$gtm_tst/com/RCVR.csh "." $portno $start_time >&! RCVR_${start_time}.out
endif
$pri_shell "$pri_getenv; cd $PRI_SIDE; $MUPIP replicate -source -needrestart -instsecondary=$gtm_test_cur_sec_name"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

cd $PRI_SIDE
echo "Note down zqgblmod_tn numbers after rollback on secondary"
$DSE all -dump >&! dbtn_list2.out
$tst_awk '/Current transaction/ {print $3}' dbtn_list2.out > db_tn2.out
$tst_awk '/Zqgblmod Trans/ {print $NF}' dbtn_list2.out > zqgblmod_tn.out
echo 'Verify accuracy of $ZQGBLMOD i.e. zqgblmod_tn is same as noted db curr_tn'
diff db_tn.out zqgblmod_tn.out
if (0 == $status) then
	echo "  --> zqgblmod_tn test PASS"
else
	echo "  --> zqgblmod_tn test FAIL"
endif
cd $SEC_SIDE

echo "Applying the lost transactions..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/applylt.csh a.lost 1 < /dev/null "">>&!"" imptp.out"

$gtm_tst/com/rfstatus.csh "Before_TEST_stops:"
$gtm_tst/com/dbcheck_filter.csh -extract

#Extract globals. Remove azTMP, bzTMP etc. from comparison as they were locally applied.
$MUPIP extract mumps4.gbl >>&! extr.log
$tail -n +3 mumps4.gbl | $grep -v "^\^[abcd]zTMP(" > mumps4.glo

diff mumps2.glo mumps4.glo >& trans2.diff
if (-z trans2.diff) then
	echo "Lost transaction applying passed"
else
	echo "TEST FAILED: mumps2.glo and mumps4.glo differs"
endif
$gtm_tst/com/checkdb.csh
