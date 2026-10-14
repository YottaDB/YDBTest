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
echo "# [YDB#1297] A SimpleThreadAPI process sent a fatal signal while a non-YottaDB thread is inside      #"
echo "# malloc() dies with a core instead of hanging                                                       #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# A signal sent with kill() goes to whichever thread the kernel picks. If that thread did not hold the"
echo "# YottaDB engine lock, it forked the core itself, either when the engine lock holder told it to or at"
echo "# once if it could take the engine lock. If it had been interrupted inside malloc(), its fork() waited"
echo "# forever for the malloc() arena lock that the interrupted malloc() holds, since glibc's fork() takes"
echo "# those locks in a process with more than one thread. The process never died, and wrote neither a"
echo "# core nor a YDB_FATAL_ERROR file."
echo "#"
echo "# The program below has a main thread that makes no YottaDB call and loops on malloc() and free(), and"
echo "# a worker thread that makes the YottaDB calls. Without the fix, step 2 of each stage usually prints"
echo "# WRONG. A Debug build dumps the core without forking in SimpleThreadAPI mode, so the subtest runs"
echo "# only with a pro build."
echo

set file = ydb1297_stapi_kill
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
if ($status) then
	echo "WRONG : linking $file failed. The linker output follows."
	cat $file.map
	exit 1
endif

set stagenum = 0
foreach mode (busy idle)
	@ stagenum++
	if ("busy" == $mode) then
		echo "# Stage $stagenum : the worker thread loops on ydb_set_st(), so a thread usually holds the engine lock"
	else
		echo "# Stage $stagenum : the worker thread makes one ydb_set_st() call and then waits, so no thread holds the"
		echo "#           engine lock"
	endif
	echo

	echo "# Step 1 : start [./$file $mode] in the background"
	echo "#          expect it to print ready once the worker's first ydb_set_st() call has returned"
	(./$file $mode < /dev/null >& $mode.out & ; echo $! >&! $mode.pid) >& bg_$mode.out
	set pid = `cat $mode.pid`
	$gtm_tst/com/wait_for_log.csh -log $mode.out -message "ready" -duration 120
	if ($status) then
		echo "WRONG : the program did not print ready. Its output follows."
		cat $mode.out
	else
		echo "PASS : the program is ready"
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
		$gtm_tst/com/wait_for_proc_to_die.csh $pid >& wait_for_proc_to_die_$mode.logx
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
			mv $corename hidden_expected_${mode}_$corename
		end
	endif
	ls -1 YDB_FATAL_ERROR* >& /dev/null
	if ($status) then
		echo "WRONG : no YDB_FATAL_ERROR file"
	else
		echo "PASS : YDB_FATAL_ERROR file found"
		foreach fatalname (YDB_FATAL_ERROR*)
			mv $fatalname hidden_expected_${mode}_$fatalname
		end
	endif
	# The message holds the pid and uid, so keep the check's output out of the reference file
	$gtm_tst/com/check_error_exist.csh $mode.out KILLBYSIGUINFO >& check_error_exist_$mode.logx
	if ($status) then
		echo "WRONG : no %YDB-F-KILLBYSIGUINFO message. The process output follows."
		cat $mode.out
	else
		echo "PASS : %YDB-F-KILLBYSIGUINFO message seen"
	endif
	echo
end

echo "# Done"
