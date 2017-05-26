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
echo "Simulating stop on receiver server in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG rkill_${kill_time}.logx

echo "Before receiver stop >>>>" 	>>& $KILL_LOG
echo "Current directory: $SEC_SIDE" 	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER	>>& $KILL_LOG
$psuser |$grep -E "mupip|mumps" 	>>& $KILL_LOG

# Get PIDS for all process on Secondary side
set pids = `$MUPIP replicate -receiv -checkhealth |& $tst_awk '/PID.*Receiver/ {print $2}'`
#################################
echo "kill -15 $pids"			 >>& $KILL_LOG
kill -15 $pids
if ($status) then
	echo "TEST-E-receiver_stop.csh KILL FAILED" >>& $KILL_LOG
else
	foreach pid ($pids)
		$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
		echo "$pid has finished" >>& $KILL_LOG
	end
endif
#################################
echo "After receiver stop: >>>>" 	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 	>>& $KILL_LOG
$psuser |$grep -E "mupip|mumps"		>>& $KILL_LOG
echo "Receiver stopped!"
#=== End crash ===
