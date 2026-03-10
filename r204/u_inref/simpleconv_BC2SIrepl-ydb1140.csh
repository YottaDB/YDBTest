#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test is partially modeled on v54003/u_inref/maxregseqno.csh
echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test simpler conversion of a BC replicating instance to an SI replicating instance'
echo '# For source of test case, see: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1140#note_3125328789'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

# simpleconv_BC2SIrepl-ydb1140 converts a secondary BC replication instance to an SI replication instance, so
# disable automatic creation of supplementary instances.
setenv test_replic_suppl_type 0
if ($?gtm_db_counter_sem_incr) then
	if (8192 <= $gtm_db_counter_sem_incr) then
		# When gtm_db_counter_sem_incr is 8192 or more, restarting the secondary's receiver server
		# at the end of the test causes the following errors to be issued:
		#   %YDB-I-TEXT, Error incrementing the ftok semaphore counter
		#   %SYSTEM-E-ENO34, Numerical result out of range
		# So, limit the value of this environment variable to 4096.
		setenv gtm_db_counter_sem_incr 4096
	endif
endif
set tlsid = ""
if ($?gtm_test_tls) then
	if ("TRUE" == "$gtm_test_tls") then
		set tlsid = " -tlsid=INSTANCE2"
	endif
endif

echo "# Create database with journaling enabled"
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
echo

echo "# Start primary and secondary servers and make some updates on source server"
$MSR START INST1 INST2 RP
echo "# On primary, run a mumps process to continually perform updates until the test completes"
($gtm_dist/mumps -run ydb1140a^ydb1140 >&! ydb1140a.out & ; echo $! >&! mumps.pid) >&! mumps-bg.out
echo "# On secondary, wait up to 300 seconds for the 10th update to the primary database to complete before continuing the test"
$MSR RUN INST2 "$gtm_dist/mumps -run ydb1140b^ydb1140 >&! ydb1140b.out"
$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/ydb1140b.out -message 'READY' -duration 10
echo

echo "# On secondary, stop receiver and passive source server."
$MSR RUN INST2 "$MUPIP replic -receiv -shut -time=0 >>&! rcvr_shut.out"
$MSR RUN INST2 "$MUPIP replic -source -shut -time=0 >>&! rcvr_shut.out"
echo

echo "# On primary, take a backup of the replication instance file."
$MSR RUN INST1 "$MUPIP backup -replinstance=src_backup.repl >>&! mupip_backup.out"
$MSR RUN SRC=INST1 RCV=INST2 "cp src_backup.repl __RCV_DIR__/src_backup.repl"
echo

echo "# On secondary, determine the current Journal Sequence Number, then change the Journal Sequence Number of the"
echo "# backup replication instance file (copied over from INSTA) to match the determined BC replica Journal Sequence Number."
$MSR RUN INST2 "$MUPIP replic -edit -show $gtm_repl_instance >&! rcvr_show.out"
set rcvr_jnl_seqno = `grep '^HDR Journal Sequence Number' $SEC_SIDE/rcvr_show.out | awk '{print $NF}' | sed 's/\[//;s/\]//;'`
$MSR RUN INST2 "$MUPIP replic -edit -change -offset=0x0090 -size=0x0008 -value=$rcvr_jnl_seqno src_backup.repl"
echo
echo "# On secondary, create a new supplementary replication instance file."
$MSR RUN INST2 "$MUPIP replicate -instance_create -supplementary -name=INSTANCE2"
echo

echo "# On secondary, switch the journal files and cut the back links as one can no longer rollback the database to its pre-supplementary (i.e. pre-SI replication) state."
$MSR RUN INST2 "$MUPIP set -replication=on -reg "'"*" $tst_jnl_str -noprevjnlfile'
echo

echo "# On secondary, start the passive source server but with -updok to indicate updates are now allowed in this environment."
$MSR RUN INST2 "$MUPIP replic -source -start -passive -log=rcvr_source_restart.log -instsecondary=INSTANCE1 -updok"
echo

echo "# On secondary, start the receiver server with -updateresync and -initialize to indicate this is a supplementary receiver and is communicating with its BC source for the first time."
$MSR RUN RCV=INST2 "$MUPIP replic -receiver -start -listen=__RCV_PORTNO__ -log=rcvr_receiver_restart.log -updateresync=src_backup.repl -initialize$tlsid"
echo

echo "# On primary, run [set ^y=1]"
$MSR RUN INST1 '$gtm_dist/mumps -run %XCMD "set ^y=1"'
echo "# On secondary, run [zwrite ^y] and wait up to 300 seconds for the previous update to propagate from the primary. Expect [^y=1]."
$MSR RUN INST2 '$gtm_dist/mumps -run ydb1140c^ydb1140'
echo "# On primary, confirm that the instance is NOT a supplementary instance"
$MSR RUN INST1 '$MUPIP replic -editinstance -show mumps.repl |& grep "Supplementary Instance"'
echo "# On secondary, confirm that the instance IS a supplementary instance"
$MSR RUN INST2 '$MUPIP replic -editinstance -show mumps.repl |& grep "Supplementary Instance"'

$gtm_dist/mumps -r %XCMD "set ^stop=1"	# Stop running updates on the primary
$gtm_tst/com/wait_for_proc_to_die.csh `cat mumps.pid`

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
