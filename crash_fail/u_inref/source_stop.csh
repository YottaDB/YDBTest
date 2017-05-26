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
# PRIMARY FAILURE Simulation
#
cd $PRI_SIDE
echo "Simulating mupip stop of primary source server in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG pkill_${kill_time}.logx

echo "Before Primary stopped >>>>" 	>>& $KILL_LOG
echo "Current directory: $PRI_SIDE"	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 	>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps" 	>>& $KILL_LOG

$MUPIP replicate -source -checkhealth >&! health
set pids=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health`
#################################
echo "kill -15 $pids" 			>>& $KILL_LOG
kill -15 $pids
if ($status) then
	echo "TEST-E-source_stop.csh KILL FAILED" >>& $KILL_LOG
else
	foreach pid ($pids)
		$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
		echo "$pid has finished" >>& $KILL_LOG
	end
endif
#################################
#
echo "After Primary stopped>>>>" 	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 	>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps" 	>>& $KILL_LOG
echo "Primary Source Server Failed!"
#=== End Crash ===
