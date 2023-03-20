#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : PRIMARY SERVER CRASH, BACKLOG AND FAILOVER (6.17 and 6.18)
#

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # This test does a failover and so disable -trigupdate

# This subtest does a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
$gtm_tst/com/dbcreate.csh mumps 3 125 1000 4096 2000 4096 2000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "GTM Process starts in background..."
setenv gtm_test_jobid 1
setenv gtm_test_dbfillid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
# Wait for 50,000 transactions/seqnos to happen on source side. Need to wait for 3600 seconds to account for slow ARMV6L.
$gtm_tst/com/wait_for_transaction_seqno.csh +50000 SRC 3600

if ($gtm_test_jnl_nobefore) then
	# If NOBEFORE_IMAGE journaling, we need to take a backup of the db in order to restore after a fetchresync rollback.
	# Before this site (current SRC) is crashed, we need to ensure that the transactions backed up here (at least)
	# should have been commited in the current secondary.
	# This is because, after a failover, if this backed-up database is used as secondary, it should not be ahead of primary
	mkdir bak1
	$MUPIP backup -replinstance=bak1 "*" bak1 >& backup.out
	set trns_bkup=`$grep "Journal Seqnos up to" backup.out | $tst_awk '{gsub("0x","") ; print $5}'`
	set trnno=`$gtm_tst/com/radixconvert.csh h2d $trns_bkup | $tst_awk '{print $5}'`
	# Wait for 50,000+ seqnos to be processed on receiver side. Need to wait for 3600 seconds to account for slow ARMV6L.
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh $trnno 3600"
else
	# We waited above for 50,000 transactions to happen on primary side (A). But it is possible the secondary (B) received
	# and/or processed almost none of this. So wait until at least a few transactions (1000) are processed on the secondary
	# that way `^%imptp` settings (which are global sets done in the beginning of imptp.m) are available for later
	# `checkdb.csh` call. This is needed since A is going to later start getting updates from B (when B becomes the primary)
	# and if B received almost none of the updates with `gtm_test_fillid = 1`, then the `checkdb.csh` done at the end of the
	# test for `gtm_test_dbfillid = 1` will fail due to almost none of the `^%imptp*` global nodes available.
	# The failure symptom we have seen is the following (in a call from checkdb.m)
	#	$ZSTATUS="2,loadinfofileifneeded+5^imptp,%SYSTEM-E-ENO2, No such file or directory"
	# And this is because `^%imptp(fillid,"trigger")` was undefined and/or `^endloop` was undefined (both because
	#	B had processed only 4 updates at the time it was shut down even though A had a backlog of 50000+ relative to B.
	# Need to wait below for 3600 seconds to account for slow ARMV6L.
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh 1000 3600"
endif

$gtm_tst/com/rfstatus.csh "BEFORE_PRI_A_CRASH:"

# Shut down Secondary (B)
echo "Shutting down Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

# Wait for source server backlog to reach 100+ seqnos. Need to wait for 3600 seconds to account for slow ARMV6L.
$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 3600

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/primary_crash.csh


# QUICK FAIL OVER #
echo "DOING QUICK FAIL OVER..."
$DO_FAIL_OVER


# PRIMARY SIDE (B) UP
setenv tst_buffsize 33554432
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"


# SECONDARY SIDE (A) UP
cd $SEC_SIDE
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.mjl*" cp
echo '$gtm_tst/com/mupip_rollback.csh -fetchresync=portno -losttrans=fetch.glo *'
$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback.log
$grep "successful" rollback.log

if ($gtm_test_jnl_nobefore) then
	# NOBEFORE_IMAGE journaling. Test various things.
	echo "==> Checking for existence of RLBKJNLNOBIMG message"
	$grep RLBKJNLNOBIMG rollback.log | $head -n 1
	echo "==> Checking for existence of RLBKLOSTTNONLY message"
	$grep RLBKLOSTTNONLY rollback.log
	echo "==> Checking that repeated rollback with -fetchresync produces the same output and lost transaction file"
	$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch1.glo "*" >>&! rollback1.log
	echo " -> Diffing fetch.glo fetch1.glo"
	diff fetch.glo fetch1.glo
	echo " -> Diffing rollback.log rollback1.log (ignoring timestamps and fetchresync messages)"
	cat rollback.log | $grep GTM | $grep -vE "MUJNLSTAT|FILERENAME|FILECREATE|Gtmrecv_fetchresync" > tmp_rollback.log
	cat rollback1.log | $grep GTM | $grep -vE "MUJNLSTAT|FILERENAME|FILECREATE|Gtmrecv_fetchresync" > tmp_rollback1.log
	diff tmp_rollback.log tmp_rollback1.log
	echo "==> Checking that rollback with -resync does NOT error out and produces the same output and lost transaction file"
	@ resync_seqno = `$grep "RESYNC SEQNO" rollback.log | sed 's/.*SEQNO is //g' | $tst_awk '{print $1}'`
	$gtm_tst/com/mupip_rollback.csh -resync=$resync_seqno -losttrans=fetch2.glo "*" >>&! rollback2.log
	echo " -> Diffing fetch.glo fetch2.glo (expect only PRIMARY versus SECONDARY difference in lost transaction file)"
	# Some machines just say "Binary files differ" in case of UTF-8 data
	# To avoid the discrepancy, remove the header and expect the files not to differ
	$tail -n +2 fetch.glo >&! fetch.glo.tmp
	$tail -n +2 fetch2.glo >&! fetch2.glo.tmp
	diff fetch.glo.tmp fetch2.glo.tmp
	echo " -> Diffing rollback.log rollback2.log (ignoring timestamps and fetchresync messages)"
	cat rollback.log | $grep GTM | $grep -vE "MUJNLSTAT|FILERENAME|FILECREATE|Gtmrecv_fetchresync" > tmp_rollback.log
	cat rollback2.log | $grep GTM | $grep -vE "MUJNLSTAT|FILERENAME|FILECREATE|Gtmrecv_fetchresync" > tmp_rollback2.log
	diff tmp_rollback.log tmp_rollback2.log
	echo "==> Checking that rollback without -fetchresync or -resync errors out with RLBKNOBIMG message"
	$gtm_tst/com/mupip_rollback.csh -losttrans=fetch3.glo "*"
	echo "==> Checking that backward recovery using NOBEFORE_IMAGE errors out with MUUSERLBK message because of crashed journal file"
	$MUPIP journal -recover -backward "*"

	# Restore from backup here in order to be able to restart this instance
	# As for the journal files, the current .mjl file would have the crash bit set. So we cannot keep it
	# while turning replication=on (or else we would get a MUUSERLBK error). So move the .mjl file away
	# and restore the .mjl_<timestamp> file that the mupip backup (we did early on in the test) renamed
	# away. That is guaranteed to be a cleanly terminated journal file which is in sync with the db and repl.
	$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.repl *.mjl" mv nozip
	cp bak1/* .
	$tst_awk -F/ '/FILERENAME/ {print gensub(/(.*mjl)(_.*)/, "mv \\1\\2 \\1", "g", $NF)}' backup.out > backup_mv.csh
	tcsh -v backup_mv.csh >& backup2.out
	# Redirect the set -replication=on output to a file, since the order of regions is non-deterministic
	$MUPIP set -replication=on $tst_jnl_str -reg "*" >&! replic_on.out
endif

$gtm_tst/com/RCVR.csh "." $portno $start_time >&! RCVR_${start_time}.out
$gtm_tst/com/rfstatus.csh "AFTER_PRI_SEC_RESTART:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh "5" < /dev/null "">>&!"" imptp.out"
source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out; if ($status) exit 1
sleep $test_sleep_sec_short

echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
# This is a crash test, so use dbcheck_filter.csh instead of dbcheck.csh
