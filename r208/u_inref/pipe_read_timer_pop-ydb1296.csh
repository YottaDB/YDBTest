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
echo "# [YDB#1296] A timed READ of a PIPE device returns when its timeout expires, even if the timer       #"
echo "# pops between two read() calls                                                                      #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# A timed READ of a PIPE relies on the timer's SIGALRM to interrupt a blocking read(). If the timer"
echo "# popped after one read() returned a partial line and before the next read() started, nothing"
echo "# interrupted that read(), and the READ waited for more input forever."
echo "#"
echo "# White-box case 412 makes the READ wait for its timer to pop after each read() that returns input,"
echo "# which makes the race happen every time. Without the fix, stage 2 prints WRONG. Stage 1 is a control"
echo "# without the white-box case."
echo

# The white-box case is in the M mode read path
$switch_chset M >&! switch_chset.log

# Bound each stage with "timeout" so that a hung READ fails the subtest instead of hanging it
foreach stage (1 2)
	if (1 == $stage) then
		echo "# Stage 1 : READ x:5 from a PIPE that writes a partial line and keeps the PIPE open"
		unsetenv gtm_white_box_test_case_enable gtm_white_box_test_case_number gtm_white_box_test_case_count
		unsetenv ydb_white_box_test_case_enable ydb_white_box_test_case_number ydb_white_box_test_case_count
	else
		echo "# Stage 2 : the same, with white-box case 412 making the timer pop between two read() calls"
		setenv ydb_white_box_test_case_enable 1
		setenv ydb_white_box_test_case_number 412
	endif
	echo '# Command : $gtm_dist/mumps -run ydb1296'
	echo '#   expect x to be "DSE> ", $TEST to be 0, and the READ to take less than 60 seconds'
	timeout 120 $gtm_dist/mumps -run ydb1296 >&! stage$stage.out
	set stat = $status
	cat stage$stage.out
	if (0 != $stat) then
		echo "WRONG : mumps exited with status $stat, expected 0 (124 means it was still running after 120 seconds)"
	endif
	echo
end
unsetenv ydb_white_box_test_case_enable ydb_white_box_test_case_number
echo "# Done"
