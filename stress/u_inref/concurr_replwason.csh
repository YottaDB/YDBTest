#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test is intended to test that GT.M handles any state changes to REPLICATION (from ON to WAS_ON) gracefully.
# This state change can happen if jnl_file_lost is called which can happen for lots of reasons.
# The most frequent of those we have seen are
#	a) Disk space issues and hence unable to write to the journal file on disk
#	b) Permissions issue (no write permission on directory containing journal files) causing a process
#		to not be able to create a new generation journal file.
# It is not easily possible to simulate case (a) so this test is going to trigger jnl_file_lost through case (b).
#
# To test that all components of GT.M run fine in this WAS_ON state, a copy of the stress/concurr_small subtest is taken
# and modified to create the WAS_ON state. REORG will be running concurrently. A lot of other concurrent runners
# in the concurr_small subtest (like mupip-reorg-upgrade-downgrade, mupip backup etc.) switch journal files which poses
# problems with the intent of this test so they are skipped in this test.
#
# The test starts with INST1 -> INST2; INST1 -> INST3 and then tries to do INST2 -> INST3, which won't work if INST1 is non-suppl and INST2,INST3 is suppl
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn 1
alias knownerror 'mv \!:1 {\!:1}x ; $grep -vE "\!:2" {\!:1}x >&! \!:1 '

# Until fake_enospc fixes go in, unsetenv gtm_custom_errors for this test to avoid failures due to rts_errors in
# jnl_file_lost. See GTM-7575 for more details.
unsetenv gtm_custom_errors

# MUPIP RUNDOWN currently does not handle the case of a shm with counter overflow that is also read-only.
# When that code issue is addressed, this test needs to re-enable counter overflow and do a MUPIP RUNDOWN of the help database at the end to cleanup after itself.
unsetenv gtm_db_counter_sem_incr	# To prevent help database encountering counter overflow and in turn have leftover ipcs at the end of the test

# We don't want the INST1->INST2 to error out with a REPLBRKNTRANS because the source server couldn't get the sequence numbers from
# the journal file. So, bump up the tst_buffsize to 128 MB to ensure the INST1->INST2 source server continues replication for a
# longer time. See <backlog_caught_up_journalpoolsize> for more details.
# Update: Recently, on some boxes (especially strato, carmen and beowulf), we still see REPLBRKNTRANS error on the INST1->INST2
# source server. It seems like these boxes are generating updates at a rate that is a lot higher than the rate at which they are
# being sent to the other side. At this point, it is not clear whether it is a code issue or a system setup issue. For now, increase
# the buffer size on all the boxes to 256 MB to allow for more journal records to be placed in the shared memory. If the failures
# still persist we need to analyze further to see if the slowdown is really happening and if so, what's causing it.
# On some boxes, like lester, a large buffsize causes IPCs problem if there are already too many IPCs left over. Keep it at 128 MB
# on lester.
if ("HOST_HP-UX_PA_RISC" != "$gtm_test_os_machtype") then
	setenv tst_buffsize 268435456
else
	setenv tst_buffsize 134217728
endif

# Since the test induces a REPLBRKNTRANS, we don't want the source server to get it, too, so disable JNLFILEONLY
# and forced overflow.
setenv gtm_test_jnlfileonly 0
unsetenv gtm_test_jnlpool_sync

echo "# Bump up the tst_buffsize to ensure the INST1->INST2 does not error out with REPLBRKNTRANS"		>> settings.csh
echo "setenv tst_buffsize $tst_buffsize" 									>> settings.csh

# Since we are intentionally introducing a GTM-E-REPLBRKNTRANS error,
# use a white box test case to prevent an assert failure in gtmsource_readfiles.c.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 28

echo "# Since we are intentionally introducing a GTM-E-REPLBRKNTRANS error,"			>> settings.csh
echo "# use a white box test case to prevent an assert failure in gtmsource_readfiles.c"	>> settings.csh
echo "setenv gtm_white_box_test_case_enable $gtm_white_box_test_case_enable"			>> settings.csh
echo "setenv gtm_white_box_test_case_number $gtm_white_box_test_case_number"			>> settings.csh

if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# is_syncio has been randomly set by instream.csh to either "" or ",sync_io"
	setenv tst_jnl_str "${tst_jnl_str}${is_syncio}"
	cat >> settings.csh << EOF
# journal options from stress - concurr_replwason:
setenv tst_jnl_str $tst_jnl_str
EOF

endif
# The test uses 3 instances INST1, INST2, INST3 with INST1 being the root primary and INST2/INST3 being secondaries.
#	INST1  --> INST2
#	INST1  --> INST3
#
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate_base.csh mumps 3 255 2048 4096
unsetenv gtm_repl_instance
$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log
#
$MSR RUN INST2 "$gtm_tst/com/dbcreate_base.csh mumps 3 255 2048 4096"
$MSR RUN INST2 'unsetenv gtm_repl_instance; $MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log'
#
$MSR RUN INST3 "$gtm_tst/com/dbcreate_base.csh mumps 3 255 2048 4096"
$MSR RUN INST3 'unsetenv gtm_repl_instance; $MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log'
setenv gtm_repl_instance mumps.repl
#
# use an external filter in the source and receiver servers
setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^extfilter"
setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^extfilter"
#
$MSR STARTRCV INST1 INST2 helper
$MSR STARTRCV INST1 INST3 helper
# Start the source server. Because the source server also starts an external filter, make sure you define
# an environment variable that records the file name that will be used for logging purposes. Since the source
# server is started across multiple instances (INST2 and INST3 as secondaries) we need to ensure this is defined
# uniquely for each secondary.
setenv filterlog "filter_inst2.out"
$MSR STARTSRC INST1 INST2
unsetenv filterlog
#
##
$MSR RUN INST1 '$MUPIP integ -r "*"  >>& integ.out'
$MSR RUN INST2 '$MUPIP integ -r "*"  >>& integ.out'
#
$MSR RUN SRC=INST1 RCV=INST2 "$gtm_tst/com/rfstatus.csh BEFORE"
$MSR RUN RCV=INST2 SRC=INST1 "$gtm_tst/com/rfstatus.csh BEFORE: < /dev/null"

# Set different autoswitchlimits for different region journal files.
#	8Mb for AREG, 9.7Mb for BREG, 200Mb for DEFAULT
# Note that BREG's autoswitch is greater than TWICE AREG's.
# These values are chosen such that assuming equal update rate for AREG and BREG, if BREG has switched one journal file,
# we are guaranteed that AREG would have switched two journal files. The moment AREG has switched once, we turn
# off write permissions to the journal directory so the second switch of AREG would end up with a REPLJNLCLOSED
# error. Thus waiting for BREG to switch once is the same as waiting for the REPLJNLCLOSED error to occur.
# Note that choosing BREG's autoswitch to be EXACTLY TWICE that of AREG might not necessarily guarantee the above
# hence choosing a little more than TWICE.
#
# Also AREG jnl files go to a subdirectory ajnl. Similarly BREG -> bjnl, DEFAULT -> cjnl.
#
mkdir ajnl
mkdir bjnl
mkdir cjnl

$MUPIP set "$tst_jnl_str,autoswitch=16384,alloc=4096,exten=4096,file=ajnl/a.mjl" -reg AREG
$MUPIP set "$tst_jnl_str,autoswitch=19456,alloc=4096,exten=5120,file=bjnl/b.mjl" -reg BREG
$MUPIP set "$tst_jnl_str,autoswitch=409600,alloc=4096,exten=4096,file=cjnl/c.mjl" -reg DEFAULT

# Take a backup of the database for later forward recovery
\mkdir ./save1; \cp *.dat* save1

# Load triggers first if applicable
if ($gtm_test_trigger) then
	# Test has specified -trigger and this platform supports triggers.
	# Load test-specific trigger definitions in the database.
	$MUPIP trigger -triggerfile=$gtm_tst/$tst/inref/replwason.trg -noprompt >& trg_replwason.log
endif

# Spawn off concurrent GT.M updates
$GTM << xyz
	do start^replwason
xyz

echo "=>Get the pid of source server"
$MSR RUN INST1 '$MUPIP replic -source -checkhealth >& checkhealth.tmp ; cat checkhealth.tmp' >& checkhealth.out
set srcpid = `$tst_awk '/PID.*Source/{print $2}' checkhealth.out`
echo "=>Source server PID = $srcpid"

# Wait for AREG journal file to have switched at least once (Wait max of 60 minutes)
# a.mjl_new is a temporary file that is created during the journal switch. So not using a.mjl_* to detect a switch
set now_time = `date +%s`
@ max_wait = $now_time + 3600
echo "=>Waiting for AREG journal file to have switched at least once"
while ($now_time < $max_wait)
	date			>>! ajnl.out
	ls ajnl/a.mjl_[0-9]*	>>& ajnl.out
	if !($status) then
		break
	endif
	#if source server is not alive, break out of infinite loop
	$gtm_tst/com/is_proc_alive.csh $srcpid
	if ($status) then
		break
	endif
	sleep 1
	set now_time = `date +%s`
end

if ($now_time >= $max_wait) then
	echo "TEST-E-TIMEOUT waiting for AREG journal switch : `ls ajnl/a.mjl*`"
endif

# Note down last seqno of the most recent previous generation a.mjl_* file.
# This is used later to check that all seqnos upto this have been sent across from INST1 to INST2 and INST3.
# Note that a.mjl_new is a temporary file that is created during the journal switch.
# We should filter out such files while determining the most recent previous generation journal file.
# Since renamed files have a timestamp at the end, look for files with the name starting with a number after the .mjl_
echo "=>Get value of last seqno of the most recent previous generation a.mjl_* file"
set prevjnl = `ls -1art ajnl/a.mjl_[0-9]* | $tail -n 1`
set goodseqno = `$MUPIP journal -show=header -forward -noverify $prevjnl |& $grep "End Region Sequence Number" | $tst_awk '{print $5}'`
echo "=>Last seqno in prevjnl is GTM_TEST_DEBUGINFO $prevjnl is $goodseqno"

# Remove write permissions on "ajnl" subdirectory
# This will trigger a REPLJNLCLOSED error whenever the current autoswitchlimit is exceeded on the current generation ajnl/a.mjl
echo "=>Removing write permissions on ajnl subdirectory"
chmod u-w ajnl

# Flush journal buffer contents to journal file on disk so we have at least some 2Mb worth of updates in journal files
# of all regions for the source server (from INST1 to INST3) to send across later.
echo "=>Flush journal buffer contents to journal file on disk so we have at least some sizable worth of updates in the file"
$DSE << dse_eof >&! dse_all_buff.log
	all -buff
dse_eof

# Check that AREG has replication state WAS_ON
echo "=>Check that AREG has replication state WAS_ON"
set cntr = 0
while ($cntr < 1000)
	if (-e dse_df.log) then
		mv dse_df.log dse_df_`date +%H%M%S`.log
	endif
	$gtm_tst/com/get_dse_df.csh "CHECK_REPL_WAS_ON" ""
	$grep "Replication State" dse_df.log | $grep "WAS_ON" >&! dse_check_was_on.log
	if (! $status) then
		# WAS_ON state reached
		break
	endif
	sleep 1
	@ cntr = $cntr + 1
end
if ($cntr >= 1000) then
	echo "AREG did not reach [WAS_ON] state even after 1000 seconds of wait. Exiting.."
	echo "=>Stop running GT.M processes"
	$GTM << xyz
		do stop^replwason
xyz
	exit 1
endif
mv dse_df.log repl_dse_df_1.log
$grep -E "^  Journal File:|Replication State" repl_dse_df_1.log

# Check that REPLJNLCLOSED message is NOT generated as an application-error in any of the GT.M .mjo files
# We rely on the test system framework to do this check in *.mjo* files at the end of the test.
echo '=>Check for absence of REPLJNLCLOSED error in any *.mjo* has been deferred to the test framework at the end of the test'

# Check that a checkhealth at this point indicates the REPLJNLCLOSED error
echo "=>Check that checkhealth now indicates REPLJNLCLOSED error"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat ; $MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__'
knownerror $msr_execute_last_out "GTM-E-REPLJNLCLOSED"

# Start reorg AFTER REPLJNLCLOSED message was generated
# This is necessary to avoid the case where reorg encounters permission errors in CRE_JNL_FILE.C
$MSR RUN INST1 "$gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg.out"
$MSR RUN INST2 "$gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg.out"
#
# Test that processes that newly attach to regions with repl_state=WAS_ON have no problems doing so
echo "=>Check that processes that newly attach to regions with repl_state=WAS_ON have no problems doing so"
$GTM << xyz
	do set1^replwason
xyz

# Start source server INST1 -> INST3 & Turn permissions back on ajnl subdirectory so new journal files can be created.
#
# Until V54000, the source server could switch to new journal files if it notices the discontinuity in the journal
# seqno BEFORE write permissions were turned back on in the ajnl subdirectory. This was fixed as part of C9J07-003156
# so the source server should never create new journal files. In order to test that fix, we start the source server
# first (and wait for the source server to issue NOPREVLINK error so we are sure it is past the point where it would
# have previously switched journal files) and only then turn permissions back on.
#
# Now start replicating between INST1 and INST3.
# This tests that the source server when it starts reading from files in a WAS_ON database is able to send
# at least as much as it can read from the journal files even though it cannot send all of it (due to WAS_ON state)
#
# Start the source server from INST1 to INST3. Because the source server also starts an external filter, make sure you define
# an environment variable that records the file name that will be used for logging purposes. Since the source
# server is started across multiple instances (INST2 and INST3 as secondaries) we need to ensure this is defined
# uniquely for each secondary.
#
# Since a.dat should have replication state WAS_ON at this point, we expect a source server checkhealth to return with
# a REPLJNLCLOSED error. Hence skip that step in STARTSRC by setting the variable gtm_test_repl_skipsrcchkhlth to 1.
#
echo "=>Check that source server sends at least as much as it can from the journal files (even if WAS_ON state)"
setenv filterlog "filter_inst3a.out"
setenv gtm_test_repl_skipsrcchkhlth 1
$MSR STARTSRC INST1 INST3
get_msrtime
unsetenv gtm_test_repl_skipsrcchkhlth
unsetenv filterlog

echo "=>Determine the PID of the INST1->INST3 source server (used later)"
# We need the PID of the INST1->INST3 source server to ensure that the source server is indeed dead (due to the REPLBRKNTRANS)
# before proceeeding with the recover (later in the test). PID of the source server is usually got by running checkhealth. But
# as part of C9K03-003241, source server could die even before a checkhealth could be issued (if it tries to send all the
# journal records upto the WAS_ON point at which it will issue REPLBRKNTRANS). So, use the source server log to get the PID of
# the source server.
# Since on slow machines the source server startup itself can take some time, use wait_for_log before attempting to get the PID
$gtm_tst/com/wait_for_log.csh -log SRC_$time_msr.log -message "GTM Replication Source Server with Pid" -duration 300
$grep "GTM Replication Source Server with Pid" SRC_$time_msr.log >&! srcpid13.out
if !($status) then
	set srcpid13 = `$tst_awk -F"[" '{print $2}' srcpid13.out | $tst_awk -F"]" '{print $1}'`
else
	echo "TEST-E-NOPID, cannot find the PID of INST1->INST3 source server. Cannot proceed"
	echo "=>Stop running GT.M processes"
	$GTM << xyz
		do stop^replwason
xyz
	exit 1
endif
# After reaching the point where the INST1->INST3 source server needs to read the transaction corresponding to the WAS_ON
# sequence number, it will exit with a REPLBRKNTRANS error. Previously, after reaching the WAS_ON point, source server
# kept issuing the REPL_WARN or REPLWARN messages. This was fixed as part of C9K03-003241 to now issue REPLBRKNTRANS error
# instead as the source server has no way of finding the WAS_ON sequence number in AREG.
# Wait for a max of 1 hour to take into account the slow boxes
echo "=>Check that source server after reaching the WAS_ON point has issued REPLBRKNTRANS error"
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message "REPLBRKNTRANS" -duration 3600 -waitcreation'
$gtm_tst/com/check_error_exist.csh SRC_$time_msr.log REPLBRKNTRANS |& sed 's/seqno .* broken/seqno ##SEQNO## broken/'

echo "=>Turning permissions back on ajnl subdirectory before starting source server from INST1 to INST3"
chmod u+w ajnl

# Re-enable replication on those regions that lost them
echo "=>Turning replication back ON those regions that lost them"
$MUPIP set -replication=on "$tst_jnl_str,autoswitch=409600,alloc=4096,exten=4096,file=ajnl/a.mjl" -reg AREG >& replwason_jnl.log

# Check that AREG has replication state ON (not WAS_ON)
echo "=>Check that AREG has replication state ON (not WAS_ON)"
if (-e dse_df.log) then
	mv dse_df.log tmp_dse_df.log
endif
$gtm_tst/com/get_dse_df.csh "CHECK_REPL_WAS_ON" ""
mv dse_df.log repl_dse_df_2.log
if (-e tmp_dse_df.log) then
	mv tmp_dse_df.log dse_df.log
endif
$grep -E "^  Journal File:|Replication State" repl_dse_df_2.log

echo "=>Wait for the FIRST INST1->INST3 source server to die before starting the SECOND source server"
$gtm_tst/com/wait_for_proc_to_die.csh $srcpid13 3600

echo "=>Now start ANOTHER INST1->INST3 source server. This one will issue a REPLBRKNTRANS error (not NOPREVLINK)"
setenv filterlog "filter_inst3b.out"
setenv gtm_test_repl_skipsrcchkhlth 1
$MSR STARTSRC INST1 INST3
get_msrtime
unsetenv gtm_test_repl_skipsrcchkhlth
unsetenv filterlog
# We don't expect REPLBRKNTRANS error here after. So, unset whitebox test cases
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_enable

echo "=>Now wait for the REPLBRKNTRANS error to show up in the SECOND INST1->INST3 source server log"
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message REPLBRKNTRANS -duration 3600 -waitcreation'
$gtm_tst/com/check_error_exist.csh SRC_$time_msr.log REPLBRKNTRANS |& sed 's/seqno .* broken/seqno ##SEQNO## broken/'
$grep "GTM Replication Source Server with Pid" SRC_$time_msr.log >&! srcpid13_b.out
if !($status) then
	set srcpid13_b = `$tst_awk -F"[" '{print $2}' srcpid13_b.out | $tst_awk -F"]" '{print $1}'`
else
	echo "TEST-E-NOPID, cannot find the PID of INST1->INST3 source server. Cannot proceed"
	echo "=>Stop running GT.M processes"
	$GTM << xyz
		do stop^replwason
xyz
	exit 1
endif

echo "=>Check that checkhealth of the INST1->INST2 source server at this point does NOT indicate any REPLJNLCLOSED error"
$MSR RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__'

echo "=>Check that processes that attach to regions after repl_state transitioned from WAS_ON --> ON have no problems doing so"
$GTM << xyz
	do set2^replwason
xyz

# Now we have generated enough data that we can stop the running GT.M processes
echo "=>Stop running GT.M processes"
$GTM << xyz
	do stop^replwason
xyz

$MSR RUN SRC=INST1 RCV=INST2 "$gtm_tst/com/rfstatus.csh AFTER"
$MSR RUN RCV=INST2 SRC=INST1 "$gtm_tst/com/rfstatus.csh AFTER: < /dev/null"
#
# Stop reorg processes
$MSR RUN INST1 "$gtm_tst/com/close_reorg.csh >>& stress_reorg.out"
$MSR RUN INST2 "$gtm_tst/com/close_reorg.csh >>& stress_reorg.out"
#
setenv test_reorg NON_REORG
# Make sure the source server is dead
$gtm_tst/com/wait_for_proc_to_die.csh $srcpid13_b 300
# Since RF_sync will fail (SRC will fail with REPLJNLCLOSED), an explict wait_until_rcvr_backlog_clear.csh is done in INST3
$MSR RUN INST3 "set msr_dont_trace ; $gtm_tst/com/wait_until_rcvr_backlog_clear.csh"
$MSR RUN INST3 "$MUPIP replic -receiv -showbacklog" >&! showbacklog_all_1.out
set processedseqno = `$grep "last transaction processed by update process" showbacklog_all_1.out | $tst_awk '{print $1}'`
echo "=>Last seqno received at INST3 is GTM_TEST_DEBUGINFO $processedseqno"
echo "=>Checking that processed-seqno is greater than or equal to last goodseqno previously noted down"
if ($processedseqno > $goodseqno) then
	echo "Seqno check PASSED"
else
	echo "Seqno check FAILED"
endif

# Shutdown the servers
$MSR STOP INST1 INST2 ON
$MSR STOP INST3 ON
$MSR REFRESHLINK INST1 INST3

# Database level integrity check on INST1 (and INST2)
echo "=>Doing database extract diff of INST1 and INST2"
$MSR RUN INST1 "$gtm_tst/com/RF_EXTR.csh INST1 INST2"
echo ""
echo "=>Doing dbcheck of INST1"
$MSR RUN INST1 "$gtm_tst/com/dbcheck_base.csh"
echo ""
echo "=>Doing dbcheck of INST2"
$MSR RUN INST2 "$gtm_tst/com/dbcheck_base.csh"
echo ""
echo "=>Doing dbcheck of INST3 (with partial updates)"
$MSR RUN INST3 "$gtm_tst/com/dbcheck_base.csh"

# Application level check on INST1 (and INST2)
echo "=>Application level check on INST1 (and INST2) : Should PASS"
$GTM << xyz
	do allverify^replwason
xyz

# Application level check on INST3 (should FAIL)
echo "=>Application level check on INST3 : Should FAIL since replication from INST1 was incomplete due to jnl_file_lost error"
$MSR RUN INST3 "$gtm_exe/mumps -run allverify^replwason"
knownerror $msr_execute_last_out "GTM-E-GVUNDEF"

# Replicate remaining transactions from INST2 to INST3 (since INST2 does not have REPLJNLCLOSED issues)
echo ""
echo "=>Replicating post-jnl_file_lost seqnos from INST2 to INST3"
$MSR START INST2 INST3 PP
$MSR STOP INST2 INST3 ON

# Do database level integrity of INST3 after completing the updates
echo ""
echo "=>Doing dbcheck of INST3 (with complete updates)"
$MSR RUN INST3 "$gtm_tst/com/dbcheck_base.csh"

# Do database extract cmp -s of INST1 and INST3 (should PASS now)
echo ""
echo "=>Doing database extract diff of INST1 and INST3 (with complete updates)"
$MSR RUN INST1 "$gtm_tst/com/RF_EXTR.csh INST1 INST3"

# Redo Application level check on INST3 (should now PASS)
echo ""
echo "=>Application level check on INST3 : Should PASS now that INST2 has propagated all remaining updates to INST3"
$MSR RUN INST3 "$gtm_exe/mumps -run allverify^replwason"

#
source $gtm_tst/com/bakrestore_test_replic.csh
setenv test_reorg NON_REORG
#
# Take a backup of the db and journal files before forward recovery
echo ""
echo "=>INST1 : Take a backup of the db and journal files into save2 before forward recovery"
\mkdir ./save2; \cp {*.dat*,*.mjl*} save2; \cp -r ajnl bjnl cjnl save2;
#
# Following is for testing journal and database match
echo "=>Save extract from current database in INST1..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! origdata.glo
\rm -f tmp.glo
#
# Do forward recovery on SECONDARY (INST2). This should pass as we did not trigger the jnl_file_lost error there.
# Then compare database extract of primary and secondary. They should match.
# This tests that the journal records written by the primary (when repl_state=WAS_ON) did get sent across to the
# secondary even though they did not get recorded in the primary's journal file.
#
echo ""
echo "=>Do forward recovery on INST2 and check that db extract matches between INST1 and INST2"
$MSR RUN INST2 "rm -f *.dat*; $MUPIP create >& mupip_create2.out"
$MSR RUN INST2 '$MUPIP set -journal="enable,off,nobefore" -reg "*" >& jnlon2.out'
$MSR RUN INST2 '$MUPIP journal -recover -forward -verbose -fence=none  "*" >& forw_recover2.log; set stat1=$status; $grep successful forw_recover2.log'
echo "Doing database extract diff of INST1 and INST2 after forward recovery on INST2"
source $gtm_tst/com/bakrestore_test_replic.csh
$MSR RUN INST1 "$gtm_tst/com/RF_EXTR.csh INST1 INST2"
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
unsetenv test_replic
#
# Restore db from when we had saved before in save1
# Do forward recovery on PRIMARY (INST1). This will fail because we intentionally triggered jnl_file_lost.
# We expect JNLDBTNNOMATCH error from forward recovery.
echo ""
echo "=>Do forward recovery on INST1 and check that we get JNLDBTNNOMATCH error (due to induced jnl_file_lost error)"
$MSR RUN INST1 "rm -f *.dat*; cp -p save1/*.dat ."
echo "$MUPIP journal -recover -forward -verbose -fence=none *"
$MUPIP journal -recover -forward -verbose -fence=none  "*" >& forw_recover1.log
set stat1=$status
$grep "successful" forw_recover1.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "TEST-E-RECOVFAIL Mupip recover -forw failed (as expected)"
endif
@ errcnt = `$grep JNLDBTNNOMATCH forw_recover1.log | wc -l`
if ($errcnt == 0) then
	echo "TEST-E-NOTNMISMATCH: Expecting JNLDBTNNOMATCH error in forward recovery but did not find any"
else
	echo "JNLDBTNNOMATCH error found in forw_recover1.log (as expected)"
endif
$gtm_tst/com/check_error_exist.csh forw_recover1.log JNLDBTNNOMATCH NOPREVLINK MUNOACTION |& sed 's/beginning transaction number .*, but /beginning transaction number ##TRANSACTION_NO##, but /'

if (! $gtm_test_jnl_nobefore) then
	#
	# Do backward recovery on PRIMARY (INST1). This should pass.
	#
	echo "=>INST1 : Restore db and journal files (from save2) to test backward recovery"
	\mkdir ./save3
	\mv *.dat* *.mjl* ajnl bjnl cjnl save3
	\cp -r ./save2/* .
	echo "$MUPIP journal -recover -backward -verbose '*' -since=0 0:0:1"
	$MUPIP journal -recover -backward "*" -verbose -since=\"0 0:0:1\" >& back_recover.log
	set stat1=$status
	$grep "successful" back_recover.log
	set stat2=$status
	if ($stat1 != 0 || $stat2 != 0) then
		echo "TEST-E-RECOVFAIL Mupip recover -back failed"
	endif
	echo "=>Extact from database after backward recovery..."
	$MUPIP extract tmp.glo >>& extract.out
	if ($status) echo "Extract failed"
	$tail -n +3  tmp.glo >! backglo.glo
	\rm -f tmp.glo
	echo "=>diff origdata.glo backglo.glo (db after original set of updates with db after backward recovery)"
	$tst_cmpsilent origdata.glo backglo.glo
	if ($status) then
		echo "TEST failed in MUPIP recover -BACKWARD"
	else
		echo "No diff found (as expected)"
	endif
	#
endif
$gtm_tst/com/dbcheck_filter.csh -nosprgde
