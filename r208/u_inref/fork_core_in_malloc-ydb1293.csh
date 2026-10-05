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

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1293] A process sent a fatal signal while inside malloc() dies with a core instead of hanging #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# A fatal signal sent to a process inside malloc() defers the exit until malloc() returns, but the"
echo "# signal handler forked for a core right away. fork() runs the pthread_atfork() prepare handlers, and"
echo "# an allocator whose handler takes the lock that the interrupted malloc() holds (ASAN's does) waits"
echo "# for it forever. The process never died, and wrote neither a core nor a YDB_FATAL_ERROR file."
echo "#"
echo "# White box case WBTEST_HOLD_FORK_LOCK_IN_MALLOC (413) stands in for such an allocator. Before the first"
echo "# malloc() of 64MiB or more, it takes a lock that its own prepare handler also takes, and holds it for"
echo "# 5 seconds. Without the fix, step 2 prints WRONG."
echo

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 413

cat > ydb1293.m << CAT_EOF
ydb1293	; Grow the stringpool past 64MiB, so it does a malloc() that WBTEST_HOLD_FORK_LOCK_IN_MALLOC stops
	for i=1:1:100 set x(i)=\$justify(i,1048576)
	write "WRONG : the process was not killed",!
	quit
CAT_EOF

echo "# Step 1 : start [yottadb -run ydb1293] in the background with white box case 413 enabled"
echo "#          expect it to report that it holds the fork lock in malloc()"
($ydb_dist/yottadb -run ydb1293 < /dev/null >& ydb1293.out & ; echo $! >&! ydb1293.pid) >& bg.out
set pid = `cat ydb1293.pid`
$gtm_tst/com/wait_for_log.csh -log ydb1293.out -message "WBTEST_HOLD_FORK_LOCK_IN_MALLOC : holding the fork lock" -duration 120
if ($status) then
	echo "WRONG : the process did not report that it holds the fork lock in malloc(). Its output follows."
	cat ydb1293.out
else
	echo "PASS : the process holds the fork lock in malloc()"
endif
echo

echo "# Step 2 : kill -4 <pid>"
echo "#          expect the process to die within 60 seconds"
kill -4 $pid
set waited = 0
while ($waited < 60)
	$gtm_tst/com/is_proc_alive.csh $pid
	if ($status) break
	sleep 1
	@ waited++
end
$gtm_tst/com/is_proc_alive.csh $pid
if ($status) then
	echo "PASS : the process died"
else
	echo "WRONG : the process is still alive 60 seconds after the signal"
	kill -9 $pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pid >& wait_for_proc_to_die.logx
endif
echo

echo "# Step 3 : check what the process left behind"
echo "#          expect a core file, a YDB_FATAL_ERROR file and a %YDB-F-KILLBYSIGUINFO message"
ls -1 core* >& /dev/null
if ($status) then
	echo "WRONG : no core file"
else
	echo "PASS : core file found"
	foreach corename (core*)
		mv $corename hidden_expected_core_$corename
	end
endif
ls -1 YDB_FATAL_ERROR* >& /dev/null
if ($status) then
	echo "WRONG : no YDB_FATAL_ERROR file"
else
	echo "PASS : YDB_FATAL_ERROR file found"
	foreach fatalname (YDB_FATAL_ERROR*)
		mv $fatalname hidden_expected_$fatalname
	end
endif
# The message holds the pid and uid, so keep the check's output out of the reference file
$gtm_tst/com/check_error_exist.csh ydb1293.out KILLBYSIGUINFO >& check_error_exist.logx
if ($status) then
	echo "WRONG : no %YDB-F-KILLBYSIGUINFO message. The process output follows."
	cat ydb1293.out
else
	echo "PASS : %YDB-F-KILLBYSIGUINFO message seen"
endif

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
echo
echo "# Done"
