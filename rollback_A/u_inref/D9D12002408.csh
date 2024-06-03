#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Reduce epoch interval to reduce required memory.
# Default epoch_interval is 300 for pro and 30 for dbg.
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=18"

setenv gtm_test_forward_rollback 0	# This test causes disk full situation due to multiple backups of db/jnl taken by mupip_rollback.csh if set to 1
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
		# Note this needs to be done before the dbcreate.csh call so receiver side also inherits this env var.
$gtm_tst/com/dbcreate.csh mumps 9 125 1000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
setenv test_sleep_sec 15
setenv test_sleep_sec_short 5

echo "GTM Process starts in background..."
setenv gtm_test_jobcnt 3
$gtm_tst/$tst/u_inref/tp_ntp_fill.csh >>&! tp_ntp_fill.out
sleep $test_sleep_sec

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
sleep $test_sleep_sec_short

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh

# PRIMARY SIDE (A) UP
# #######################################################################
# The following lines are commented out as they sometimes have been seen to take up a lot of disk space.
# They can be re-enabled in case of a test failure for analysis and hence are left around.
#	$pri_shell "cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip"
#	$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
# #######################################################################
#
echo "Primary:mupip_rollback.csh -losttrans=lost1.glo *"
echo "$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
#
echo "Secondary:mupip_rollback.csh -losttrans=lost1.glo *"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >>&! rollback2.log; $grep "successful" rollback2.log'
#
setenv start_time `date +%H_%M_%S`
echo "Restarting Primary (A)..."
$gtm_tst/com/SRC.csh "." $portno $start_time >& START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_RESTART"
echo "Wait for rollback on secondary and connection..."
# SECONDARY SIDE (B) UP
echo "Restarting Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$GTM << aaa
d verify^tpntp
d in0^pfill("set",1)
d in0^pfill("ver",1)
aaa
$gtm_tst/com/dbcheck_filter.csh -extract
