#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# This subtest does a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
setenv gtm_test_crash 1
$gtm_tst/com/dbcreate.csh mumps 3 125 1000 4096 2000 4096 2000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "GTM Process starts in background..."
setenv gtm_test_jobid 1
setenv gtm_test_dbfillid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
# Wait for some transactions
$gtm_tst/com/wait_for_transaction_seqno.csh +50000 SRC 600

if ($gtm_test_jnl_nobefore) then
	# If NOBEFORE_IMAGE journaling, we need to take a backup of the db in order to restore after a fetchresync rollback.
	# Before this site (current SRC) is crashed, we need to ensure that the transactions backed up here (at least)
	# should have been commited in the current secondary.
	# This is because, after a failover, if this backed-up database is used as secondary, it should not be ahead of primary
	mkdir bak1
	$MUPIP backup -replinstance=bak1 "*" bak1 >& backup.out
	set trns_bkup=`$grep "Journal Seqnos up to" backup.out | $tst_awk '{gsub("0x","") ; print $5}'`
	set trnno=`$gtm_tst/com/radixconvert.csh h2d $trns_bkup | $tst_awk '{print $5}'`
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh $trnno"
endif

$gtm_tst/com/rfstatus.csh "BEFORE_PRI_A_CRASH:"

# Shut down Secondary (B)
echo "Shutting down Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

# Wait for some source server backlog
$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 300

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
sleep $test_sleep_sec_short

echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
# This is a crash test, so use dbcheck_filter.csh instead of dbcheck.csh
