#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Called by socket_opts-gtmf135169.csh when the backgrounded server of a write-readback round is still alive after the
# wait for that server gave up. Records where the server is stuck and then leaves the server alive, so that the subtest
# hangs until the test framework reports a hung subtest and someone can examine the stuck server.
#
# $1 - pid recorded in the *-server.pid file, which is the subshell that runs strace
# $2 - name of the round (for example 10-opts), used in the names of the files created here
#
# The server is the mumps process that strace traces. A debugger cannot attach to a process that strace traces, so no
# C stack trace is taken here. What is recorded instead, in this order, is
# 1) The state of the mumps process and the system call that process is in, from /proc/<pid>.
# 2) The M stack and the state of the devices of the mumps process. MUPIP INTRPT makes the process create a
#    YDB_JOBEXAM.ZSHOW_DMP_<pid>_<n> file if the process still handles signals.
# While the mumps process is blocked in a system call, the -o file of strace has all system calls of the mumps process
# up to that one.
#
# The script then waits for the mumps process to end, with no time limit. A SIGKILL of strace (strace does not end on
# a SIGTERM) leaves the mumps process alive and no longer traced, so that a debugger can attach to it. The subtest
# continues once the mumps process ends.

set subshellpid = $1
set round = $2
set log = server-hang-$round.outx	# .outx so that the test framework does not scan this file for errors

echo "# Server of round $round still alive after the wait. Processes below pid $subshellpid :" >>& $log
set stracepid = `pgrep -P $subshellpid -x strace`
if ("" == "$stracepid") then
	echo "# No strace process found below pid $subshellpid" >>& $log
	ps -f --ppid $subshellpid >>& $log
	exit 1
endif
set serverpid = `pgrep -P $stracepid`
ps -f -p $subshellpid,$stracepid >>& $log
if ("" == "$serverpid") then
	echo "# No process found below strace pid $stracepid" >>& $log
	exit 1
endif
ps -f -p $serverpid >>& $log

echo "# State of server pid $serverpid at `date`" >>& $log
$grep -E "^(State|SigQ|SigPnd|ShdPnd|SigBlk|SigIgn|SigCgt):" /proc/$serverpid/status >>& $log
echo "# /proc/$serverpid/syscall (system call number, 6 arguments, stack pointer, program counter) :" >>& $log
cat /proc/$serverpid/syscall >>& $log
echo "# Open files of server pid $serverpid :" >>& $log
ls -l /proc/$serverpid/fd >>& $log

echo "# Sending MUPIP INTRPT to server pid $serverpid at `date`" >>& $log
$MUPIP intrpt $serverpid >>& $log
sleep 5
ls -l *JOBEXAM.ZSHOW_DMP_${serverpid}_* >>& $log

set msg = "server of wrtest-$round (pid $serverpid, traced by strace pid $stracepid) is stuck."
set msg = "$msg See $log, raw-$round.outx (system calls) and *JOBEXAM.ZSHOW_DMP_${serverpid}_* (M stack)."
set msg = "$msg For a C stack, kill -KILL $stracepid, then attach a debugger to pid $serverpid."
set msg = "$msg The subtest waits until pid $serverpid ends."
echo "TEST-E-SERVERHANG $msg"
echo "TEST-E-SERVERHANG $msg" >>& $log
echo "# Waiting for server pid $serverpid to end, with no time limit, at `date`" >>& $log
while (-e /proc/$serverpid)
	sleep 60
end
echo "# Server pid $serverpid ended at `date`" >>& $log
$gtm_tst/com/wait_for_proc_to_die.csh $stracepid 30 >>& $log
exit 0
