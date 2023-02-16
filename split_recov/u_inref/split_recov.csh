#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : SPLIT JOURNAL FILE RECOVERY (6.23)
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
if ($LFE == "E") then
        setenv test_sleep_sec 180
else
        setenv test_sleep_sec 60
endif

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # this test does a failover and so disable -trigupdate

# The test does a failover. So A->P is not possible
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

# For this test buffer size is 1 MB and always keep log files
setenv test_debug 1
setenv tst_buffsize  1048576
$gtm_tst/com/dbcreate.csh mumps 6 125 1000 512,1024,4096
setenv portno `$sec_shell 'cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
# GTM Process starts in background
$gtm_tst/com/imptp.csh "5" >&! imptp.out
$gtm_tst/com/wait_for_transaction_seqno.csh +1000 SRC $test_sleep_sec "" noerror
$gtm_tst/com/rfstatus.csh "BEFORE_RECEIVER_SHUT"
# Force receiver to shut down
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
# Create backlog
$gtm_tst/com/wait_for_transaction_seqno.csh +1000 SRC $test_sleep_sec "" noerror

cd $PRI_SIDE
# SPLIT two journal files
$gtm_tst/com/srcstat.csh "BEFORE_SPLIT_REGA_REGB"
$MUPIP set -file $tst_jnl_str a.dat
$MUPIP set -file $tst_jnl_str b.dat
$gtm_tst/com/wait_for_transaction_seqno.csh +1000 SRC $test_sleep_sec "" noerror
# SPLIT one journal files on B side again
$gtm_tst/com/srcstat.csh "BEFORE_SPLIT_REGA"
$MUPIP set -file $tst_jnl_str a.dat
$gtm_tst/com/wait_for_transaction_seqno.csh +1000 SRC $test_sleep_sec "" noerror

# now stop GTM
$gtm_tst/com/endtp.csh
echo "Source shut down ..."
$gtm_tst/com/SRC_SHUT.csh "." >>&! SHUT_${start_time}.out

# FAIL OVER #
$DO_FAIL_OVER
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP:"" < /dev/null"


cd $SEC_SIDE
if ($?test_debug == 1) then
	$gtm_tst/com/backup_dbjnl.csh bak '*.dat *.mjl*' cp nozip
endif
echo "mupip_rollback.csh -verbose -fetchresync=portno -losttrans=fetch.glo *  >&! rollback.log"
$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=$portno -losttrans=fetch.glo "*"  >&! rollback.log
$grep -E "successful|Broken" rollback.log
if ($tst_remote_host == $tst_org_host) then
	cp -f $SEC_SIDE/fetch.glo $PRI_SIDE/fetch.glo
else
	$rcp $SEC_SIDE/fetch.glo "$tst_remote_host":"$PRI_SIDE"/fetch.glo
endif
$gtm_tst/com/RCVR.csh "." $portno $start_time >&! RCVR_${start_time}.out
$pri_shell "$pri_getenv; cd $PRI_SIDE; $MUPIP replicate -source -needrestart -instsecondary=$gtm_test_cur_sec_name"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

echo "Applying the lost transactions..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/applylt.csh "fetch.glo" 1 < /dev/null "">>&!"" imptp.out"
echo "Apply some more transactions..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh "5" < /dev/null "">>&!"" imptp.out"
$gtm_tst/com/wait_for_transaction_seqno.csh +1000 SRC $test_sleep_sec "" noerror
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh  < /dev/null "">>&!"" imptp.out"


$gtm_tst/com/rfstatus.csh "Before_TEST_stops:"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
