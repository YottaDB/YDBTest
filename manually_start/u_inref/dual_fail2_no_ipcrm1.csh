#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2015 Fidelity National Information		#
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
#
# TEST : DUAL SITE FAILURE : CASE 2
#
#	Case 2
#-------------------------------------------------------|---------------------------------------
#		                 A 			|     	       B
#-------------------------------------------------------|---------------------------------------
#	     P (d - 100, R = 95)			|      	S (d - 95, R = 95)
#	     P (101 - 150, R = 95)			|	    X
#	     	X					|	    X
#	     	X					|	P (96 - 120, R = 95)
#	     S (B = min(95, 95) = 95, LT = 96 - 150)	|	P (120 - d, R = 95)
#-------------------------------------------------------|---------------------------------------
#
#

source $gtm_tst/$tst/u_inref/setenvdualfail.csh
# For this test buffer size is forced to be 16 MB
setenv tst_buffsize 16777216
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 1000 2048
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
# GTM Process starts in background
echo "Multi-process Multi-region GTM starts on primary (A)..."
$gtm_tst/com/imptp.csh >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_sec

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh ""NO_IPCRM"""
# primary continues to run and creates a backlog
sleep $test_sleep_sec

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh "NO_IPCRM"
sleep 5

# FAIL OVER #
echo "Doing Fail over."
$DO_FAIL_OVER

if ($?test_debug) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl* *.gld *.repl' cp nozip"
endif

# ROLLBACK ON PRIMARY SIDE (B)
echo "Doing rollback on (B):"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'echo $MUPIP journal -rollback -backward -losttrans=lost1.glo >>&! rollback1.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP journal -rollback -backward -losttrans=lost1.glo "*" >>&! rollback1.log; $grep -w "successful" rollback1.log | sort'
# PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh "AFTER_PRI_B_UP:" < /dev/null"


# SECONDARY SIDE (A) UP
cd $SEC_SIDE
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl* *.gld *.repl' cp nozip
endif

echo "Doing rollback on (A):"
echo "$MUPIP journal -rollback -backward -fetchresync=$portno -losttrans=fetch.glo " >>&! rollback2.log
$MUPIP journal -rollback -backward -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log
$grep -w "successful" rollback2.log
echo "Restarting (A) as secondary..."
$gtm_tst/com/RCVR.csh "." $portno $start_time >&!  START_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
sleep $test_sleep_sec
echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
