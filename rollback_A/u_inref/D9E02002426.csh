#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information		#
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
setenv gtm_test_mupip_set_version "disable"     # -autorollback (online rollback) cannot work with V4 database format
$gtm_tst/com/dbcreate.csh mumps 5 125 1000
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
setenv test_debug 1
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
$MUPIP set -journal=enable,on,before,epoch=30 -reg "*" |& sort -f
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=30 -reg '*' |& sort -f"
#
echo "GTM Process starts "
$GTM << xyz
d main^d9002426
halt
xyz
sleep 70	# epoch_interval + 30+
$GTM << xyz
d bkgrnd^d9002426
halt
xyz
#
# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
# primary continues to run and creates a backlog
sleep 10
#
# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh
#
# PRIMARY SIDE (A) UP
$pri_shell "cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1"
setenv start_time `date +%H_%M_%S`
echo "$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
if ($status) exit
#
echo "Restarting Primary (A)..."
$gtm_tst/com/SRC.csh "." $portno $start_time >& START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_RESTART"
echo "Restart gtm..."
$GTM << xyz
d verify^d9002426
d main^d9002426
halt
xyz
# SECONDARY SIDE (B) UP
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >>&! rollback2.log; $grep "successful" rollback2.log'
echo "Restarting Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE;  setenv gtm_test_autorollback TRUE ; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/dbcheck_filter.csh -extract
