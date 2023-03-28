#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
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
if !($?gtm_test_replay) then
	set mustop_sigquit_todo = `$gtm_exe/mumps -run rand 2`
	echo "# Randomly chosen stop/fail/crash option : $mustop_sigquit_todo"	>>&! settings.csh
	echo "setenv mustop_sigquit_todo $mustop_sigquit_todo"			>>&! settings.csh
endif
if ($mustop_sigquit_todo) then
	set mustop_sigquit = "MU_STOP"
	set expected_error = "YDB-F-FORCEDHALT"
else
	set mustop_sigquit = "SIGQUIT"
	set expected_error = "YDB-F-KILLBYSIG" # Note Go will put out KILLBYSIG while non-Go will put out KILLBYSIGUINFO
endif
# For this test buffer size is forced to be 16 MB
setenv tst_buffsize 16777216
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 1000 2048

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
# GTM Process starts in background
echo "Multi-process Multi-region GTM starts on primary (A)..."
$gtm_tst/com/imptp.csh >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_sec

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh ""$mustop_sigquit"""
# primary continues to run and creates a backlog
sleep $test_sleep_sec

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh "$mustop_sigquit"
sleep 5

foreach file (SRC_${start_time}.log impjob_imptp0.mje1 impjob_imptp0.mje2 impjob_imptp0.mje3)
	$gtm_tst/com/check_error_exist.csh $file $expected_error >>&! check_errors.outx
	if ($status) then
		echo "The expected error $expected_error not seen in log $file"
	endif
	# Errors are caught even if the file is renamed to impjob_imptp0.mje1x. So zip it
	$tst_gzip ${file}x
end
foreach file (RCVR_${start_time}.log passive_${start_time}.log)
	$sec_shell "$sec_getenv; cd $SEC_SIDE ; $gtm_tst/com/check_error_exist.csh $file $expected_error >>&! check_errors.outx ;"' if ($status) echo '$expected_error' not seen in '$file
end
# FAIL OVER #
echo "Doing Fail over."
$DO_FAIL_OVER

$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl* *.gld *.repl' cp nozip"
# ROLLBACK ON PRIMARY SIDE (B)
echo "Doing rollback on (B):"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'echo mupip_rollback.csh -losttrans=lost1.glo >>&! rollback1.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log;	\
									$grep "JNLSUCCESS" rollback1.log'
# PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh "AFTER_PRI_B_UP:" < /dev/null"


# SECONDARY SIDE (A) UP
cd $SEC_SIDE
mkdir ./bak2; cp {*.dat,*.mjl*,*.gld,*.repl} ./bak2
echo "Doing rollback on (A):"
echo "mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo " >>&! rollback2.log
$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log
$grep "JNLSUCCESS" rollback2.log
echo "Restarting (A) as secondary..."
$gtm_tst/com/RCVR.csh "." $portno $start_time >&!  START_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
sleep $test_sleep_sec
echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
# Force a dse buffer flush here, as the backlog will be too high
# In such cases, shutdown process might take longer than 4 minutes and will fail.
$pri_shell "$pri_getenv ; cd $PRI_SIDE ; $gtm_tst/com/dse_buffer_flush.csh"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; $gtm_tst/com/dse_buffer_flush.csh"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
