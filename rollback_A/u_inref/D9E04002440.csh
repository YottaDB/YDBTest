#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
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
# This subtest does a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
setenv test_debug  1
setenv gtm_test_crash 1
$gtm_tst/com/dbcreate.csh mumps 8 125-325 900-1150 512,1024,4096 2000 4096 2000
$MUPIP set -journal=enable,on,before,epoch=30 -reg AREG
$MUPIP set -journal=enable,on,before,epoch=60 -reg BREG
$MUPIP set -journal=enable,on,before,epoch=150 -reg DEFAULT
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
# GTM Process starts in background
echo "Multi-process Multi-region GTM starts on primary (A)..."
setenv gtm_test_maxdim 15
setenv gtm_test_parms "1,7"
setenv gtm_test_dbfill "IMPRTP"
$gtm_tst/com/imptp.csh >&! imptp.out
sleep 290

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/corrupt_jnlrec.csh a b c >>& corrupt_jnlrec.out "
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak22 '*.dat *.mjl* *.gld *.repl' cp nozip"
# primary continues to run and creates a backlog
sleep 60

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh
$gtm_tst/com/corrupt_jnlrec.csh c e >>& corrupt_jnlrec.out
$gtm_tst/com/backup_dbjnl.csh bak11 '*.dat *.mjl* *.gld *.repl' cp nozip

# FAIL OVER #
echo "Doing Fail over."
$DO_FAIL_OVER

# ROLLBACK ON PRIMARY SIDE (B)
echo "Doing rollback on (B):"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh -verbose -noerror -losttrans=lost1.glo >>&! rollback1.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$gtm_tst/com/mupip_rollback.csh -verbose -noerror -losttrans=lost1.glo "*" >>&! rollback1.log; $grep "successful" rollback1.log'
# PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh "AFTER_PRI_B_UP:" < /dev/null"
#
#
# SECONDARY SIDE (A) UP
echo "Doing rollback on (A):"
echo "$gtm_tst/com/mupip_rollback.csh -verbose -noerror -fetchresync=$portno -losttrans=fetch.glo " >>&! rollback2.log
$gtm_tst/com/mupip_rollback.csh -verbose -noerror -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log
$grep "successful" rollback2.log
echo "Restarting (A) as secondary..."
$gtm_tst/com/RCVR.csh "." $portno $start_time >&!  START_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
sleep 30
echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
$gtm_tst/com/checkdb.csh
