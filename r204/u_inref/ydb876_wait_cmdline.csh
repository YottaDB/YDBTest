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

# Usage: ydb876_wait_cmdline.csh <pid> <pattern>
#
# Waits for up to 60 seconds for the command line of process <pid> to match the extended regular expression
# <pattern>. The command line is /proc/<pid>/cmdline with each NUL byte shown as a space.
#
# A process started in the background is first a copy of the shell that started the process, with the command
# line of that shell, and gets the command line of the command only when the copy execs the command. A caller
# that reads the command line of a background process must first wait, with this script, for the command line
# of the command to show up.
#
# Prints nothing if the command line matched. Prints a TEST-E-FAIL line and the command line if not.
set pid = "$1"
set pattern = "$2"
@ tries = 0
while ($tries < 600)
	cat /proc/$pid/cmdline |& tr '\0' ' ' | $grep -q -E "$pattern"
	if (0 == $status) exit 0
	sleep 0.1
	@ tries++
end
echo "TEST-E-FAIL : the command line of pid $pid did not match [$pattern] in 60 seconds. The command line is :"
cat /proc/$pid/cmdline |& tr '\0' ' '
echo
exit 1
