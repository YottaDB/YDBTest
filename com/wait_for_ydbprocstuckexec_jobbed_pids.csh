#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Wait for backgrounded dse processes (from %YDBPROCSTUCKEXEC) to finish before moving on as otherwise they can cause a
# TEST-E-LSOF test failure due to those backgrounded dse processes still accessing mumps.dat after this script exits.
# The backgrounded dse process id can be found in %YDBPROCSTUCKEXEC*_dse.out but the parent of the dse process can be
# found in %YDBPROCSTUCKEXEC*.out in a line "pid of jobbed process is PID". Therefore we look for the parent pid below
# and wait for it to terminate (at which point we are guaranteed the child dse process would also have terminated).

set filepat="%YDBPROCSTUCKEXEC*.out"
set nonomatch
set filereal=$filepat
unset nonomatch
if ("$filereal" == "$filepat") then
	# Files of the form %YDBPROCSTUCKEXEC*.out do not exist. Nothing to do.
	exit
endif

# There are 2 potential types of backgrounded pids that we need to look for.
#	%YDBPROCSTUCKEXEC*.out     will contain a line of the form "pid of jobbed process is 38498"
#	%YDBPROCSTUCKEXEC*_dse.out will contain a line of the form "pid of DSE or its parent is 38499"
# Wait for both types of processes to terminate.
foreach grepstr ("pid of DSE or its parent is" "pid of jobbed process is")
	set pidlist = `grep "$grepstr" $filepat | $tst_awk '{print $NF}'`
	foreach pid ($pidlist)
		$gtm_tst/com/wait_for_proc_to_die.csh $pid
	end
end

