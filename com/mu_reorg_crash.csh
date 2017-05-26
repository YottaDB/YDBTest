#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Kills mupip reorg process on either current or, remote machine
# This can be call for either primary or, secondary side
# Should be called twice with correct environemnt to kill both reorg processes
# This can be used for non-replication tests too.
#
echo "Simulating crash on mupip reorg process in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG mu_reorg_${kill_time}.logx

date >>& $KILL_LOG
echo "Before MUPIP REORG crash >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
alias ps_mrc  "$psuser | $grep -v grep "
ps_mrc >>& $KILL_LOG

# touch REORG.END to signal online_reorg.csh to end (this prevents new reorgs from starting up)
# kill the current reorg process
# Wait for the parent process (pid from mu_reorg_parent.pid) to die
# remove REORG.END
# PID for MUPIP REORG
set ppid=`$grep PID mu_reorg_parent.pid | $tst_awk '{printf("%s ",$2);}'`
echo "The ppid is $ppid" >> $KILL_LOG
echo "------------------" >>! ${KILL_LOG}_ps
set rpid=`ps_mrc | $grep "mupip" | tee -a ${KILL_LOG}_ps | $tst_awk '{if ($3 == '$ppid') printf($2);}'`
\touch REORG.END
set wait_proc_status = 0 # To signal if the kill was successful or not
if ( "" == "$rpid") then
	echo "TEST-I-REORG_CRASH Not found, will not look again..." >> $KILL_LOG
else
	set killit = "/bin/kill -9"	# BYPASSOK kill -9
	echo "$killit $rpid" >>& $KILL_LOG
	$killit $rpid >>& $KILL_LOG
	if ($status) then
		$gtm_tst/com/is_proc_alive.csh $rpid	# sets $status to 0 if process is alive, 1 if process is dead
		if ($status) then
			# It is possible that once we found rpid, by the time we issue kill command, reorg process has ended.
			# We do not error out in that case, but continue
			echo "TEST-I-$killit $rpid failed. Process must have died before kill"  >> $KILL_LOG
			echo "TEST-I-REORG_NOT_CRASHED. Note that the reorg process was not crashed" >> $KILL_LOG
		else
			echo "TEST-E-$killit $rpid failed"  >> $KILL_LOG
		endif
	else
		echo "`date` : Waiting for the reorg process $rpid to die" >> $KILL_LOG
		# if the process doesn't die in an hour the test might fail.
		$gtm_tst/com/wait_for_proc_to_die.csh $rpid 3600
		if($status) then
			# The reorg process did not die in 1 hour. Should exit with an error
			set wait_proc_status = 1
		endif
	endif
endif
echo "`date` : Waiting for the parent process $ppid to die" >> $KILL_LOG
# REORG.END should stop online_reorg.csh in the immediately following iteration. But considering the below scenario,
# online_reorg.csh is signalled to stop and immediately we check for the reorg process.
# It is possible that at the time of checking there was no reorg process, but as soon as the check is done (and rpid is null)
# online_reorg.csh spawns a reorg process. So wait for the same 1 hour for the parent process to die.
$gtm_tst/com/wait_for_proc_to_die.csh $ppid 3600
if($status) then
	# online_reorg.csh is continuing to run even after an hour of wait. Signal error
	set wait_proc_status = 1
endif
\rm REORG.END

echo "After MUPIP REORG crash >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
ps_mrc >>& $KILL_LOG
date >>& $KILL_LOG
echo "MUPIP REORG crashed!"

if (0 == $wait_proc_status) then
	# The kill was successful and online_reorg.csh script exited. Exit with 0
	exit 0
else
	# Either the reorg process did not die or the online_reorg script did not exit
	exit 1
endif

