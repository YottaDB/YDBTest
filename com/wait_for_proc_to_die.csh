#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Waits (in increments of 1 second) until the input pid is no longer alive.
#
# $1 - pid to wait for
# $2 - optional max. wait time (by default it is 60 seconds), -1 implies infinite wait
# $3 - logfile path
# $4 - optionally - Do not log anything
# $5 - treat zombie/defunct process as dead
#
# Returns 0 if process is dead
# Returns 1 if process is still alive after max.wait time
#
if ($#argv == 0) then
	echo ""
	echo "$0 <pid-to-wait-for> [maxwait-time] [logfile-path] [donot-log]"
	echo ""
	exit -1
endif

@ checkpoint = 30	# default to modulo 30 for dbx analysis
if ($2 == "") then
	set sleepiters = 60
else if ($2 == "-1") then
	set sleepiters = 3600	# Sleep for 1 hour if asked to wait infinitely
	set checkpoint = 600	# don't start checking until late enough in the game
else
	set sleepiters = $2
	if (120 < $2) then
		@ checkpoint = 60	# use modulo 60 for dbx analysis since wait > 120s
	endif
endif

set logfile = wait_for_proc_to_die_`date +%H%M%S`_$$.log		# for debugging info
set info_file = psinfo_`date +%H%M%S`_$$.txt
if ($3 != "") then
	set logfile = $3/$logfile
	set info_file = $3/$info_file
endif

if ("nolog" == "$4") then
	set nolog = 1
endif
set pid = "$1"

if ("" == "$pid") then
	echo "WAITPROCALIVE-E-EMPTYPID: Empty string was passed as PID to wait_for_proc_to_die.csh"
	exit -1
endif

set onesleep = 1

set treat_defunct_as_dead = "$5"

# A pid can be reused by an unrelated process once the process being waited for has died. With pid_max at 100000 and many
# processes created per second, that can happen within the wait, and a reused pid often belongs to a kernel worker thread
# that never exits. So, where /proc is available, note the start time of the process (field 22 of /proc/<pid>/stat, in
# clock ticks since boot) at entry, and treat the process as dead if the pid later has a different start time. Field 2 of
# that file is the command name in parentheses and can contain spaces, so the fields are counted after its closing ")"
# (field 22 becomes field 20, and field 4, the parent pid, becomes field 2). A process whose parent is pid 2 (kthreadd)
# is a kernel thread and so cannot be the process a test is waiting for. Neither can a process owned by another non-root
# user when the test runs as a non-root user. Root is left out because a test can wait for a process it started as root
# (for example gtmsecshr). A test that waits as one non-root user for a process of another non-root user would need this
# check removed. These checks cover a pid reused before this point by a kernel thread or by another non-root user's
# process, but not by a root process or another process of the test user, which is waited for as if it were the original.
set starttime = ""
if (-r /proc/$pid/stat) then
	set procstat = `awk '{sub(/^.*\) /, ""); print $2, $20}' /proc/$pid/stat |& cat`
	if (2 == $#procstat) then
		if ("2" == "$procstat[1]") then
			echo "TEST-I-PIDREUSED, pid $pid is a kernel thread, so the process being waited for is dead" >>& $logfile
			exit 0
		endif
		set procuid = `stat -c %u /proc/$pid |& cat`
		set myuid = `id -u`
		if (("0" != "$procuid") && ("0" != "$myuid") && ("$procuid" != "$myuid")) then
			echo "TEST-I-PIDREUSED, pid $pid is owned by uid $procuid, not by the test's uid $myuid, so the process being waited for is dead" >>& $logfile
			exit 0
		endif
		set starttime = "$procstat[2]"
	endif
endif

@ iters = 1
while ($iters <= $sleepiters)
	$gtm_tst/com/is_proc_alive.csh $pid "" "$treat_defunct_as_dead"	# sets $status to 0 if process is alive, 1 if process is dead
	if ($status == 0) then
		if ("" != "$starttime") then
			set nowstarttime = `awk '{sub(/^.*\) /, ""); print $20}' /proc/$pid/stat |& cat`
			if ("$nowstarttime" != "$starttime") then
				echo "TEST-I-PIDREUSED, pid $pid now has start time [$nowstarttime], not [$starttime], so the process being waited for is dead" >>& $logfile
				break
			endif
		endif
		sleep $onesleep	# process is still alive, sleep some more time
	else
		break		# ready to return
	endif
	if ((( $iters % $checkpoint ) == 0 || ($iters == $sleepiters - 1)) && !($?nolog)) then
		echo "################################################################################################"	>>&! $logfile
		echo "TEST-I-DBXINFO, let's do some dbx analysis" >>& $logfile
		date >>& $logfile
		ps -p $pid >>& $logfile #BYPASSOK
		# Lookup the process name for the given PID.
		ps -p $pid | tail -n 1 >! $info_file
		set pname = `awk '{print $4}' $info_file`
		# Check whether the process is a YottaDB or GT.M executable. If so, a stack trace is needed.
		find -L $gtm_dist -maxdepth 1 -type f -executable -name $pname | grep -q .
		if (! $status) then
			# A YottaDB or GT.M executable is still running. In that case, get a C stack trace
			# to see why it is stuck.
			$gtm_tst/com/get_dbx_c_stack_trace.csh $pid $pname >>&! $logfile
			$gtm_tst/com/check_PC_INVAL_err.csh $pid $logfile
		else
			# The process is either already dead, or otherwise not a YottaDB or GT.M executable.
			# In either case, no need for a stack trace, just log the relevant details and move on.
			echo "TEST-I-UNDETERMINED_EXE, Could not determine the executable for $pid, pname determined was: $pname, ps output was:" >>& $logfile #BYPASSOK
			cat $info_file >>& $logfile
			echo "Waiting time elapsed: $iters" >>& $logfile
		endif
	endif
	@ iters = $iters + $onesleep
end
if ($iters <= $sleepiters) then
	exit 0
else
	echo "WAITPROCALIVE-E-WAITTOOLONG : Waited for $sleepiters seconds for pid $pid to die but was not successful"
	echo "WAITPROCALIVE-E-DBXINFO, please see $logfile for dbx information"
	exit -1
endif
