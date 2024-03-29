#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script checks for any background DSE processes started by %YDBPROCSTUCKEXEC and if any are found, it kills them.
# If not, any test that uses %YDBPROCSTUCKEXEC would leave dse processes still accessing the database which would cause
# the test framework to flag that test as a failure (TEST-E-LSOF message).
# Also see discussion around https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1224#note_1134814943 for more details.

set filepat="%YDBPROCSTUCKEXEC*.out"
set nonomatch
set filereal=$filepat
unset nonomatch
if ("$filereal" == "$filepat") then
	# Files of the form %YDBPROCSTUCKEXEC*.out do not exist
	exit
endif

set kill_log = kill_$$.out

# Files of the form %YDBPROCSTUCKEXEC*.out do exist
foreach file ($filereal)
	echo "# Processing file $file" >>& $kill_log
	set pid = `grep "pid of DSE or its parent is " $file | awk '{print $NF}'`
	if ("" == "$pid") then
		echo "# Skipping file $file as DSE pid line not found" >>& $kill_log
		continue
	endif
	# $pid points to the shell process id that in turn spawned off the dse process.
	# We use "pgrep" to find the list of children of $pid. And then use "kill -9" to kill those pids.
	echo "# Running [pgrep -P $pid]" >>& $kill_log
	set pidlist = `pgrep -P $pid`
	echo $pidlist >>& $kill_log
	# And then use "kill -9" to kill $pid and all its children.
	echo "# Running [kill -9 $pidlist $pid]" >>& $kill_log
	kill -9 $pidlist $pid >>& $kill_log
	foreach killpid ($pidlist $pid)
		$gtm_tst/com/wait_for_proc_to_die.csh $killpid
	end
end

# Note: We kill -9 dse processes accessing the database file. This can cause leftover ipcs if there is no other
# process accessing the database. The caller must ensure they do some database operation before they exit the test
# or else we would have a test failure with CHECK-W-SEM and/or CHECK-W-SHM symptoms. Most callers would do a dbcheck.csh
# call after this script and that would access the database and clean up the ipcs. Therefore, we don't do that step here
# but leave it to the caller. The "v54001/u_inref/C9K02003237.csh" caller does not do a dbcheck.csh and so that has an
# explicit "mupip rundown" step after the call to the current script.

