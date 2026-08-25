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

echo "#--------------------------------------------------------------------------------------------------#"
echo '# [YDB#1256] $ZSIGPROC() and %YDBPROCSTUCKEXEC must not signal when the pid is not positive         #'
echo "#--------------------------------------------------------------------------------------------------#"
echo

# READ THIS BEFORE CHANGING ANY $ZSIGPROC() CALL BELOW.
#
# Every $ZSIGPROC() call in this subtest passes signal 0, and that is a safety requirement, not a
# stylistic choice. Signal 0 is the null signal: POSIX has kill() perform its error checking and send
# NOTHING. It therefore exercises the pid check this subtest is about while being incapable of
# disturbing any process, on a fixed build or an unfixed one.
#
# That matters because the behaviour under test is, by definition, absent from a build that has
# regressed, and the pids involved are the two most destructive values kill() accepts:
#
#	pid  0	 signals EVERY PROCESS IN THE CALLER'S PROCESS GROUP
#	pid -1	 signals EVERY PROCESS THE USER IS PERMITTED TO SIGNAL
#
# A real signal with pid -1 does not stay inside the test. It reaches the whole login session - every
# ssh-agent and gpg-agent, "systemd --user", and the window manager, which exits and takes the
# desktop session with it. Running "setsid" around it does NOT help: setsid isolates the session and
# process group, and pid -1 ignores both by design. This is not a hypothetical; it is how this
# subtest was written the first time, and running it against a build without the fix logged
#
#	systemd[...]: Received SIGUSR1 from PID ... (mumps).
#	xrdp-sesexec[...]: Window manager (pid ..., display ..) exited with signal SIGUSR1.
#
# and logged the user out. Never send a real signal to a non-positive pid from a test, and do not
# rely on containment to make one safe.
#
# Stages 4 and 5 are the one place a real signal can still be reached, because %YDBPROCSTUCKEXEC has
# USR1 written into it, and each is gated on the $ZSIGPROC() stage for the same pid having passed
# first. That gate is what makes them safe, and the two are safe for different reasons:
#
#   stage 4, pid  0	the reach is the process group, which "setsid" genuinely does contain, and
#			stage 1 has shown $ZSIGPROC() rejects the pid anyway.
#   stage 5, pid -1	"setsid" would NOT contain this one. What makes it safe is stage 2 having
#			just shown that $ZSIGPROC() itself rejects -1 with EINVAL, so even if the
#			check inside %YDBPROCSTUCKEXEC were missing, the signal is refused one layer
#			down. If stage 2 failed, both layers are suspect and stage 5 does not run.
#
# What is NOT covered here: the part of the fix that stops YottaDB invoking $ydb_procstuckexec at all
# when the blocking pid is not positive. Reaching it needs a cache record left with a read in
# progress and no owner, which comes of killing a process inside a window of a few instructions in
# "db_csh_getn", and there is no reliable way to arrange that on demand.

set stage1ok = 0
set stage2ok = 0

echo '# Stage 1 : $ZSIGPROC() with a pid of 0 must return EINVAL'
echo '# Command : $ydb_dist/mumps -run %XCMD write "retcode=",$zsigproc(0,0),!'
$gtm_dist/mumps -run %XCMD 'write "retcode=",$zsigproc(0,0),!' >&! zsig_pid0.out
set act = `$tst_awk -F= '/retcode=/{print $2}' zsig_pid0.out`
if ("$act" == "22") then
	echo "PASS : returned EINVAL (22)"
	set stage1ok = 1
else
	echo "WRONG : expected retcode 22 (EINVAL), got [$act] - see zsig_pid0.out"
	echo "WRONG : a retcode of 0 means the pid check is absent and kill(0,...) was reached"
endif
echo

echo '# Stage 2 : $ZSIGPROC() with a pid of -1 must return EINVAL'
echo '# Command : $ydb_dist/mumps -run %XCMD write "retcode=",$zsigproc(-1,0),!'
$gtm_dist/mumps -run %XCMD 'write "retcode=",$zsigproc(-1,0),!' >&! zsig_pidneg.out
set act = `$tst_awk -F= '/retcode=/{print $2}' zsig_pidneg.out`
if ("$act" == "22") then
	echo "PASS : returned EINVAL (22)"
	set stage2ok = 1
else
	echo "WRONG : expected retcode 22 (EINVAL), got [$act] - see zsig_pidneg.out"
	echo "WRONG : a retcode of 0 means the pid check is absent and kill(-1,...) was reached"
endif
echo

echo '# Stage 3 : a positive pid must still work, so the check above did not break $ZSIGPROC()'
# This is the test system convention for backgrounding a process and capturing its pid (see
# v60001/u_inref/concbkup.csh). The subshell's output goes to a file, so the job notification tcsh
# writes on backgrounding does not land in the subtest output and cause reference file randomness.
(sleep 120 & ; echo $! >&! sleeppid.txt) >&! sleep_bg.out
set sleeppid = `cat sleeppid.txt`
echo '# Command : $ydb_dist/mumps -run %XCMD write "retcode=",$zsigproc(<a live pid>,0),!'
set cmd = 'write "retcode=",$zsigproc('"$sleeppid"',0),!'
$gtm_dist/mumps -run %XCMD "$cmd" >&! zsig_live.out
set act = `$tst_awk -F= '/retcode=/{print $2}' zsig_live.out`
if ("$act" == "0") then
	echo "PASS : a live process returned 0"
else
	echo "WRONG : expected retcode 0 for a live process, got [$act] - see zsig_live.out"
endif
# This kill is of a pid this subtest just created and holds in a variable, never a searched-for or
# computed one.
kill $sleeppid >& /dev/null
$gtm_tst/com/wait_for_proc_to_die.csh $sleeppid 60 wait_sleep.log "donotlog" >& /dev/null
echo '# Command : the same, after that process has gone away'
set cmd = 'write "retcode=",$zsigproc('"$sleeppid"',0),!'
$gtm_dist/mumps -run %XCMD "$cmd" >&! zsig_dead.out
set act = `$tst_awk -F= '/retcode=/{print $2}' zsig_dead.out`
if ("$act" == "3") then
	echo "PASS : a process that has gone away returned ESRCH (3)"
else
	echo "WRONG : expected retcode 3 (ESRCH) for a dead process, got [$act] - see zsig_dead.out"
endif
echo

echo "# Stage 4 : %YDBPROCSTUCKEXEC handed a blocking pid of 0 must collect nothing and signal nothing"
if (0 == $stage1ok) then
	echo "SKIPPED : stage 1 showed the pid check is absent, so this build is not poked further"
else
	echo '# Command : setsid -w env ydb_tmp=. gtm_tmp=. $ydb_dist/mumps -run %YDBPROCSTUCKEXEC BUFRDTIMEOUT <own pid> 0 1'
	# setsid is correct containment HERE and only here: this path can reach a real USR1, but with a
	# pid of 0, whose reach is the process group that setsid has just made private to this command.
	#
	# ydb_tmp and gtm_tmp are pinned to this directory because %YDBPROCSTUCKEXEC chooses where to
	# write its report by the chain ydb_tmp, gtm_tmp, ydb_log, gtm_log, /tmp. The test framework sets
	# neither of the first two, so without this the report lands in $gtm_log, which is the log
	# directory of the distribution being tested: shared between runs, and not where this subtest
	# then looks for it. Pinning them keeps the report with the rest of the subtest output.
	setsid -w env ydb_tmp=$cwd gtm_tmp=$cwd $gtm_dist/mumps -run %YDBPROCSTUCKEXEC BUFRDTIMEOUT $$ 0 1 >&! procstuck_pid0.out
	set st = $status
	if (0 == $st) then
		echo "PASS : the calling process survived"
	else
		echo "WRONG : expected exit status 0, got $st - 138 means it was killed by SIGUSR1"
	endif
	set report = `ls -t %YDBPROCSTUCKEXEC*BUFRDTIMEOUT*.out |& $grep -v "No match" | head -1`
	if ("$report" == "") then
		echo "WRONG : %YDBPROCSTUCKEXEC wrote no report"
	else
		if (0 == `$grep -c "Sending USR1" "$report"`) then
			echo "PASS : the report shows no signal was sent"
		else
			echo "WRONG : the report shows a signal was sent"
		endif
		if (0 != `$grep -c "does not name a process" "$report"`) then
			echo "PASS : the report says why it collected nothing"
		else
			echo "WRONG : the report does not explain why it collected nothing"
		endif
	endif
endif
echo
echo "# Stage 5 : the same for a blocking pid of -1, the value that would reach every process"
if (0 == $stage2ok) then
	echo 'SKIPPED : stage 2 showed $ZSIGPROC() does not reject -1, so this build is not poked further'
else
	echo '# Command : setsid -w env ydb_tmp=. gtm_tmp=. $ydb_dist/mumps -run %YDBPROCSTUCKEXEC BUFRDTIMEOUT <own pid> -1 1'
	# ydb_tmp and gtm_tmp pinned for the same reason as the previous stage.
	setsid -w env ydb_tmp=$cwd gtm_tmp=$cwd $gtm_dist/mumps -run %YDBPROCSTUCKEXEC BUFRDTIMEOUT $$ -1 1 >&! procstuck_pidneg.out
	set st = $status
	if (0 == $st) then
		echo "PASS : the calling process survived"
	else
		echo "WRONG : expected exit status 0, got $st - 138 means it was killed by SIGUSR1"
	endif
	set report = `ls -t %YDBPROCSTUCKEXEC*BUFRDTIMEOUT*.out |& $grep -v "No match" | head -1`
	if ("$report" == "") then
		echo "WRONG : %YDBPROCSTUCKEXEC wrote no report"
	else
		if (0 == `$grep -c "Sending USR1" "$report"`) then
			echo "PASS : the report shows no signal was sent"
		else
			echo "WRONG : the report shows a signal was sent"
		endif
		if (0 != `$grep -c "does not name a process" "$report"`) then
			echo "PASS : the report says why it collected nothing"
		else
			echo "WRONG : the report does not explain why it collected nothing"
		endif
	endif
endif

echo
echo "# Done"
