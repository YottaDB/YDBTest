#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Verify REQRLNKCTLRNDWN error is not issued in case relinkctl file creation was not complete"
echo "# Killing a process that is supposed to create the relinkctl file in the middle of creation"
gdb -quiet $ydb_dist/yottadb << EOF >& gdb695.out
# This turns off quit confirmations
set confirm off
# This makes GDB not ask if pending breakpoints are okay but assume they are
set breakpoint pending on
# Kill process here
break ftruncate
# This makes GDB kill process on hitting the breakpoint
commands 1
quit
end
run -run %XCMD 'set \$zroutines=".*"'
EOF

echo "# Running a routine again to see if the relinkctl file can be salvaged"
echo "# Previously before YDB695 fix, we would see errors here; now we shouldn't"
$ydb_dist/yottadb -r %XCMD 'set $zroutines=".*"'
