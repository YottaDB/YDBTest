#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Gets a C-stack trace of a process that is currently alive or a core file
# If the process is dead, this script will return an error.
#
# $1 - pid or core file to get stack trace of
# $2 - executable (gtm or mupip or dse etc.) that pid is running
#
# Returns 0 if successful
# Returns non-zero otherwise
#
set pid_core = $1
set image = $2

if ($?tst_disable_dbx) then
	echo "DBX has been disabled by the test system!"
	exit 0
endif

# If run outside the test system
if ( (! $?dbx) || (! $?tst_awk) ) then
	if (! $?gtm_tst) setenv gtm_tst $gtm_test/T990
	source $gtm_tst/com/set_specific.csh
endif
# Print stack trace of all the threads if applicable.
# Linux/HP-UX : the same command prints trace of just the one process if multi-threads are not available.
# AIX : thread command would print info about just one thread if multi-threads are not available.
# SunOS : prints no infomation if multi-threads are not available. So do "where" at the beginning too.
# Note: The tool uses two dbx commands on AIX and SunOS, one to get a list of threads and another to get trace of each. The two outputs need not be consistent relative to each other.
# i.e threads could have come in or gone away by the time the second command is executed

# The commands for corefile and pid are duplicated for AIX and SunOS because of subtle differences which couldn't be taken care of easily

if (-e $pid_core) then
	# A file exists, so $1 is a core
	set corefile = $pid_core
else
	# Assume it to be a process id
	set pid = $pid_core
endif

set threadcmd = get_dbx_c_stack_trace_get_threads_${pid_core:t}.cmd
set threadout = get_dbx_c_stack_trace_get_threads_${pid_core:t}.out
set cmdfile   = get_dbx_c_stack_trace_${pid_core:t}.cmd

if ( ("Linux" == "$HOSTOS") || ("HP-UX" == "$HOSTOS") ) then
	if ($?corefile) then
		set args = "$corefile"
	else
		set args = "-pid $pid"
	endif
	echo "" | $tst_awk '{printf "set width 0\ninfo threads\nset backtrace limit 100\nthread apply all bt\ndetach\nquit\n"}'	>& $cmdfile
	$dbx $image $args --command=$cmdfile
else if ("AIX" == "$HOSTOS") then
	if ($?corefile) then
		set args = "$image $corefile"
		echo "" | $tst_awk '{printf "thread\nquit\n"}'		>& $threadcmd
		$dbx $image $corefile < $threadcmd			>& $threadout
		$tst_awk 'BEGIN {print "thread"} /^.\$t/ {gsub(/^.\$t/,"") ; printf "thread %d\nthread current %d\nwhere\n",$1,$1,$1} END{print "quit"}' $threadout >& $cmdfile
		$dbx $image $corefile < $cmdfile
	else
		echo "" | $tst_awk '{printf "thread\ndetach\nquit\n"}'	>& $threadcmd
		$dbx -a $pid -c $threadcmd				>& $threadout
		$tst_awk 'BEGIN {print "thread"} /^.\$t/ {gsub(/^.\$t/,"") ; printf "thread %d\nthread current %d\nwhere\n",$1,$1,$1} END{print "detach\nquit"}' $threadout >& $cmdfile
		$dbx -a $pid -c $cmdfile
	endif
else if ("SunOS" == "$HOSTOS") then
	if ($?corefile) then
		echo "" | $tst_awk '{printf "threads\nquit\n"}'		>& $threadcmd
		$dbx $image $corefile < $threadcmd >& $threadout
		$tst_awk 'BEGIN {printf "where\nthreads\n"} / *t@[1-9].* / {gsub ( /^ ./,"" ) ; printf "thread %s\nwhere\nthread -info %s\n",$1,$1} END{printf "quit\n"}' $threadout >& $cmdfile
		$dbx $image $corefile < $cmdfile
	else
		echo "$pid" | $tst_awk '{printf "attach %d\nthreads\ndetach\nquit",$1}'	>& $threadcmd
		$dbx < $threadcmd >& $threadout
		$tst_awk 'BEGIN {printf "attach %d\nwhere\nthreads\n",'$pid'} / *t@[1-9].*running/ {gsub ( /^ ./,"" ) ; printf "thread %s\nwhere\nthread -info %s\n",$1,$1} END{printf "detach\nquit\n"}' $threadout >& $cmdfile
		$dbx < $cmdfile
	endif
else
	echo "GET_DBX_C_STACK_TRACE-E-PLATFORM: This platform does not have commands to get stack trace yet"
endif

set dbx_status = $status
if (0 != $dbx_status) then
	if ($?corefile) then
		echo "TEST-E-DBXERROR : Unable to get C-stack trace using $dbx $image on the core file $corefile"
	else
		set pid_alive = `ps -p $pid -o pid | $tst_awk '/[0-9]+/ {print $1}'`	# BYPASSOK ps since it is specifically ps -p
		if ( $pid_alive == "" ) then
			echo "TEST-E-DBXPIDNOTALIVE : $pid is not alive. Unable to get C-stack trace using $dbx $image on it..."
		else
			echo "TEST-E-DBXERROR : $pid is alive. Unable to get C-stack trace using $dbx $image on it due to some other reason"
		endif
	endif
endif

date >&!  get_dbx_c_stack_trace_${pid_core:t}.done
exit $dbx_status
