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

$gtm_dist/mumps -run ydb918
set program_pid=`cat parentPID.txt`
echo "# We expect an empty error file."
cat ydb918.mje
echo "# And we expect the PID in the output file."
echo "# to be the same as the PID that the .csh captured."
set mumpsPID=`cat ChildZYJOBPARENT.txt`
if ($program_pid == "") then
	echo "# the PID appears to be empty"
	echo "# program pid is $program_pid and mumpsPID is $mumpsPID"
endif
if ($program_pid == $mumpsPID) then
	echo "The PIDs were equal"
	echo "# program pid is $program_pid and mumpsPID is $mumpsPID"
else
	echo "The PIDs were not equal"
	echo "the \$ZYJOBPARENT was $mumpsPID but the csh reported PID is $program_pid"
endif
echo '# This test also runs $ZYJOBPARENT in a job created by another job'
echo '# so now we inspect the results of the Nested JOB $ZYJOBPARENT.'
set program_pid_nested=`cat childPID.txt`
set mumpsPID_nested=`cat childChildZYJOBPARENT.txt`
if ($program_pid_nested == "") then
	echo "# the PID appears to be empty"
	echo "# program pid is $program_pid_nested and mumpsPID is $mumpsPID_nested"
endif
if ($program_pid_nested == $program_pid) then
	echo "# the PID of the nested program appears to be the same as its parent's PID"
	echo "# nested PID is $program_pid_nested and the parent's PID is $program_pid"
endif
if ($program_pid_nested == $mumpsPID_nested) then
	echo "The PIDs were equal"
	echo "# program pid is $program_pid_nested and mumpsPID is $mumpsPID_nested"
else
	echo "The PIDs were not equal"
	echo "the \$ZYJOBPARENT was $mumpsPID_nested but the csh reported PID is $program_pid_nested"
endif
