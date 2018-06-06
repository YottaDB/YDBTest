#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Kills the script online_reorg_upgrd_dwngrd on either current or, remote machine
# This can be call for either primary or, seocondary side
# Should be called twice with correct environemnt to kill both reorg processes
# This can be used for non-replication tests too.
#
if (! -e mu_reorg_upgrd_dwngrd.pid) exit # means the online_reorg_upgrd_dwngrd never started

echo "Simulating crash on mupip process in `pwd`"
date
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG mu_reorg_upgrd_dwngrd_crash_${kill_time}.logx

date >>& $KILL_LOG
echo "Before MUPIP crash >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
alias ps_mrc  "$psuser | $grep -v grep "
date >>& $KILL_LOG
ps_mrc >>& $KILL_LOG

@ maxtry = 10
@ tried = 0
set wait_time = 300			# Try for a maximum of 5 minutes
set now_time = `date +%s`
@ max_wait = $now_time + $wait_time
while ($now_time <= $max_wait)
	set now_time = `date +%s`
	set flag = "found"
	# PID for MUPIP REORG
	set ppid=`$grep PID mu_reorg_upgrd_dwngrd.pid | $tst_awk '{printf("%s ",$2);}'`
	echo "The ppid is $ppid" >> $KILL_LOG
	echo "------------------ time $now_time --------------" >>! ${KILL_LOG}
	date >>& $KILL_LOG
	set rpid=`ps_mrc | $grep "mupip" | tee -a ${KILL_LOG} | $tst_awk '{if ($3 == '$ppid') printf($2);}'`
	if ( "" == "$rpid") then
		set flag = "notfound"
		echo "TEST-I-MUPIP_CRASH Not found, will look again..." >> $KILL_LOG
		date >> $KILL_LOG
		sleep 1
		continue
	endif
	date >>& $KILL_LOG
	set killit = "/bin/kill -9"	# BYPASSOK kill -9
	echo "$killit $rpid" >>& $KILL_LOG
	$killit $rpid >>& $KILL_LOG
        if ($status) then
		$gtm_tst/com/is_proc_alive.csh $rpid	# sets $status to 0 if process is alive, 1 if process is dead
        	if ($status) then
			# It is possible that once we found rpid, by the time we issue kill command, mupip process has ended.
			# We do not error out in that case, but continue
			echo "TEST-I-$killit $rpid failed. Process must have died before kill"  >> $KILL_LOG
		else
			echo "TEST-E-$killit $rpid failed"  >> $KILL_LOG
		endif
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $rpid 600
		break
	endif
	sleep 1
end
if ($now_time > $max_wait) then
	if ($flag == "notfound") echo "TEST-I-mupip process could not be found"
	echo "TEST-I-Failed to kill mupip process, will simply stop them"
	echo "The time is:"
	date
	$gtm_tst/com/close_reorg_upgrd_dwngrd.csh >>&! close_reorg_upgrd_dwngrd.out
	exit 0
endif
#
setenv reorg_upgrd_dwngrd_crash
$gtm_tst/com/close_reorg_upgrd_dwngrd.csh >>&! close_reorg_upgrd_dwngrd.out
date >>& $KILL_LOG
echo "After MUPIP crash >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
ps_mrc >>& $KILL_LOG
date >>& $KILL_LOG
echo "MUPIP crashed!"
exit 0
