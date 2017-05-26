#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# RECEIVER SERVER CRASH
#
#=== Start Crash ===
cd $SEC_SIDE
echo "Simulating fail on receiver server in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG rkill_${kill_time}.logx

echo "Before receiver fail >>>>" 	>>& $KILL_LOG
echo "Current directory: $SEC_SIDE"	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER	>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps"	>>& $KILL_LOG

# Get PIDS for all process on Secondary side
set pids = `$MUPIP replicate -receiv -checkhealth |& $tst_awk '/PID.*Receiver/ {print $2}'`
#
#################################
echo "$kill9 $pids" 			>>& $KILL_LOG
$kill9 $pids
#################################
echo "After receiver fail: >>>>" 	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 	>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps" 	>>& $KILL_LOG
echo "Receiver failed!"
#=== End crash ===
