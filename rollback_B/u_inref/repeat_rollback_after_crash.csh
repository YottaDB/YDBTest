#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Note that ideminte_rolrec does not use active primary and  secondary. So, we do not want to remove this test.
# Currently default EPOCH interval = 5 minutes
if ($?gtm_chset) then
	setenv save_chset $gtm_chset
endif
if ($?test_replic == 0) echo "This is a replic test"
if ($?test_replic == 0) exit
if ($?gtmdbglvl) then
	if (1 == $gtm_test_forward_rollback) then
		# gtmdbglvl non-zero AND forward rollback enabled has been seen to cause the test to run for a lot longer.
		# Disable this combination by unsetting gtmdbglvl.
		unsetenv gtmdbglvl
		echo '# unsetenv gtmdbglvl to reduce test runtime (since gtm_test_forward_rollback is non-zero)' >>&! settings.csh
		echo 'unsetenv gtmdbglvl' >>&! settings.csh
	endif
endif
setenv gtm_test_forward_rollback 0	# This test causes disk full situation due to multiple backups of db/jnl taken by mupip_rollback.csh if set to 1
setenv gtm_test_switches_jnl_files 1	# indicate to mupip_rollback.csh that this test switches jnlfiles explicitly
setenv test_debug 1
setenv gtm_test_tp 6
setenv gtm_test_jobcnt 6
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_crash 1
$gtm_tst/com/dbcreate.csh mumps 8 125-325 900-1150 512,1024,4096 4096 4096 4096

echo "# Multi-Process GTM Process starts in background... : GTM_TEST_DEBUGINFO : `date`"
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 120
setenv tst_seqno `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/cur_jnlseqno.csh 1 < /dev/null"`
$gtm_tst/com/endtp.csh >>&! endtp.out

# Following is just to create some pini/pfini records
$gtm_tst/com/pini_pfini.csh >>& pini_pfini.out
$GTM << aaa
set ^prefix="^"
d in2^mixfill("set",15)
d in2^numfill("set",1,2)
h
aaa
#
echo "# Multi-Process GTM Process starts in background... : GTM_TEST_DEBUGINFO : `date`"
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
#
echo "# First Switch ... : GTM_TEST_DEBUGINFO : `date`"
$gtm_tst/com/rand_jnl_on.csh ; $sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/rand_jnl_on.csh"
set num = `date | $tst_awk '{srand(); print (1 + int(rand() * 120))}'` ; sleep $num 	## Random wait
echo "# Second Switch ... : GTM_TEST_DEBUGINFO : `date`"
$gtm_tst/com/rand_jnl_on.csh ; $sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/rand_jnl_on.csh"
set num = `date | $tst_awk '{srand(); print (1 + int(rand() * 120))}'` ; sleep $num 	## Random wait
###
echo "# Secondary Crash ... : GTM_TEST_DEBUGINFO : `date`"
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
# Following sleep should be enough to take A ahead of B
sleep 60
###
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
echo "# Primary Crash ... : GTM_TEST_DEBUGINFO : `date`"
$gtm_tst/com/primary_crash.csh
###
setenv start_time `date +%H_%M_%S`
echo "# ROLLBACK1 process starts : GTM_TEST_DEBUGINFO : `date`"
echo "mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
if !($gtm_test_trigger) then
	$switch_chset M  >>&  rollback1.log
endif
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
echo "# ROLLBACK1 process ends : GTM_TEST_DEBUGINFO : `date`"
if (!($gtm_test_trigger) && ($?save_chset)) then
	$switch_chset $save_chset  >>&  rollback1.log
endif
\rm -f *.o >>& rollback1.log
$MUPIP reorg >>& off_reorg.out
###
echo "# ROLLBACK2 process starts : GTM_TEST_DEBUGINFO : `date`"
echo "mupip_rollback.csh -losttrans=lost2.glo " >>&! rollback2.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >>&! rollback2.log
$grep "successful" rollback2.log
echo "# ROLLBACK2 process ends : GTM_TEST_DEBUGINFO : `date`"
###
###
echo "# ROLLBACK3 process starts : GTM_TEST_DEBUGINFO : `date`"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo mupip_rollback.csh -losttrans=lost3.glo >>&! rollback3.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost3.glo "*" >>&! rollback3.log; \
											$grep "successful" rollback3.log'
echo "# ROLLBACK3 process ends : GTM_TEST_DEBUGINFO : `date`"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP reorg >>& off_reorg.out "
###
echo "# ROLLBACK4 process starts : GTM_TEST_DEBUGINFO : `date`"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo mupip_rollback.csh -losttrans=lost4.glo >>&! rollback4.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost4.glo "*" >>&! rollback4.log; \
											$grep "successful" rollback4.log'
echo "# ROLLBACK4 process ends : GTM_TEST_DEBUGINFO : `date`"
###
echo "# ROLLBACK5 process starts : GTM_TEST_DEBUGINFO : `date`"
echo "mupip_rollback.csh * -resync=$tst_seqno -lost=lost_trans5.log" >>&! rollback5.log
$gtm_tst/com/mupip_rollback.csh "*" -resync=$tst_seqno -lost=lost_trans5.log >>&! rollback5.log
$grep "successful" rollback5.log
echo "# ROLLBACK5 process ends : GTM_TEST_DEBUGINFO : `date`"
# Test the below from supplementary test plan
# 54) Test that -resync rollback is idempotent. That is do a -resync or -fetchresync rollback that takes the instance to
# say strm_seqno 100 with strm_index = 1. Now redo the exact same rollback command and you expect the instance
# to be at the exact same strm_seqno. A dse dump -file -supp should show the same value before and after the second rollback.
echo "# ROLLBACK5B process starts : GTM_TEST_DEBUGINFO : `date`"
$MUPIP replic -edit -show mumps.repl >&! repl_show5.out
$grep -E "GTM-I-RLBK.*SEQ" rollback5.log >&! seqnocheck5.out
$grep "Journal Sequence Number" repl_show5.out >>&! seqnocheck5.out
$gtm_tst/com/mupip_rollback.csh "*" -resync=$tst_seqno -lost=lost_trans5B.log >>&! rollback5B.log
$MUPIP replic -edit -show mumps.repl >&! repl_show5B.out
$grep -E "GTM-I-RLBK.*SEQ" rollback5B.log >&! seqnocheck5B.out
$grep "Journal Sequence Number" repl_show5B.out >>&! seqnocheck5B.out
diff seqnocheck5.out seqnocheck5B.out
echo "# ROLLBACK5B process ends : GTM_TEST_DEBUGINFO : `date`"

###
echo "# ROLLBACK6 process starts : GTM_TEST_DEBUGINFO : `date`"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo mupip_rollback.csh -resync='$tst_seqno' -losttrans=lost6.glo >>&! rollback6.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -resync='$tst_seqno' -losttrans=lost6.glo "*" >>&! rollback6.log; $grep "successful" rollback6.log'
echo "# ROLLBACK6 process ends : GTM_TEST_DEBUGINFO : `date`"
###
$tst_tcsh $gtm_tst/com/RF_EXTR.csh
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcheck_base_filter.csh"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base_filter.csh"
$gtm_tst/com/portno_release.csh
$gtm_tst/com/checkdb.csh
###
