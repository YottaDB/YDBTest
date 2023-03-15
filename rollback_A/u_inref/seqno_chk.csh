#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
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
# Rollback should make sure there is no hole in seqno after the rollback
# For this test buffer size is 1 MB and always keep log files
setenv tst_buffsize 1048576
setenv gtm_test_spanreg 0	# The test assumes that updates go to each of the 9 regions sequentially in order
				# Rest of the test's verification process depends on that assumption
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
		# Note this needs to be done before the dbcreate.csh call so receiver side also inherits this env var.
$gtm_tst/com/dbcreate.csh mumps 9 125 1000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
setenv test_sleep_sec 60
setenv test_sleep_sec_short 15
#
echo "GTM Process starts in background..."
$gtm_tst/$tst/u_inref/seqno_fill.csh >>&! seqno_fill.out
sleep $test_sleep_sec
#
# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
# primary continues to run and creates a backlog
sleep $test_sleep_sec_short
#
# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh
#
# PRIMARY SIDE (A) UP
$pri_shell "cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1"
#
$MUPIP rundown -reg "*" -override |& sort -f
echo "Journal extract on primary side before rollback ......"
$gtm_tst/$tst/u_inref/seqextr.csh
echo "Verifying journals on primary side before rollback ......"
$GTM << gtm_eof
  d chkextr^bkgrnd(1)
  h
gtm_eof
#
echo "mupip rollback on primary side ..."
echo "#mupip journal /rollback /back /losttrans=lost.glo *"
setenv start_time `date +%H_%M_%S`
echo "$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
#
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2"
# PRIMARY SIDE (A) UP
echo "Restarting Primary (A)..."
$gtm_tst/com/SRC.csh "." $portno $start_time >& START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_RESTART"
#
echo "mupip rollback on secondary side ..."
echo "#mupip journal /rollback /back /fetchresync=portno -losttrans=lost2.glo"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh  -fetchresync=$portno -losttrans=lost2.glo >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh  -fetchresync=$portno -losttrans=lost2.glo "*" >>&! rollback2.log; $grep "successful" rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$grep -E "YDB-I-RLBK.*SEQ" rollback2.log >&! seqnocheck2.out'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replic -edit -show mumps.repl >&! repl_show2.out ; $grep "Journal Sequence Number" repl_show2.out >>&! seqnocheck2.out'
# Test the below from supplementary test plan
# 54) Test that -resync rollback is idempotent. That is do a -resync or -fetchresync rollback that takes the instance to
# say strm_seqno 100 with strm_index = 1. Now redo the exact same rollback command and you expect the instance
# to be at the exact same strm_seqno. A dse dump -file -supp should show the same value before and after the second rollback.
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh  -fetchresync=$portno -losttrans=lost2B.glo "*" >>&! rollback2B.log; '
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$grep -E "YDB-I-RLBK.*SEQ" rollback2B.log >&! seqnocheck2B.out'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replic -edit -show mumps.repl >&! repl_show2B.out ; $grep "Journal Sequence Number" repl_show2B.out >>&! seqnocheck2B.out'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'diff seqnocheck2.out seqnocheck2B.out'

# SECONDARY SIDE (B) UP
echo "Restarting Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
$gtm_tst/com/dbcheck_filter.csh -extract
#
# Replication has ended.

cd $PRI_DIR
echo "Verifying database on primary side ......"
$GTM << gtm_eof
  d chkdata^bkgrnd
  h
gtm_eof
#
echo "Journal extract on primary side ......"
$gtm_tst/$tst/u_inref/seqextr.csh
#
echo "Verifying journals on primary side ......"
$GTM << gtm_eof
  d chkextr^bkgrnd(0)
  h
gtm_eof
#
