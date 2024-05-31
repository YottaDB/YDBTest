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

echo "###########################################################################################################"
echo "# Test that relinkctl file shared memory latch is salvaged/recovered after crash in 1 second (not 30 seconds)"
echo "###########################################################################################################"

# Make output the same under GT.M and YDB
setenv ydb_prompt 'GTM>'

unsetenv ydb_routines			# in case it is already set
setenv gtmroutines ".* $gtmroutines"	# set to auto relink if .m program is found in current directory

set mrtn = "ydb1083crash"
echo '# Create '$mrtn'.m to do a [write 1]'
echo ' set x=$horolog' > $mrtn.m

echo '# While inside gdb, execute [do ^x] with gtmroutines=".*". This will open relinkctl shared memory.'
echo '# As part of that it will invoke [grab_latch()] and then [rel_latch()].'
echo '# Set a breakpoint in [rel_latch()] and kill the process when it reaches there.'
echo '# This will basically create a latch holder pid that is dead.'

# The "set breakpoint pending on" line below is needed to avoid "Make breakpoint pending on future shared library load"
# prompt from gdb where it waits for a y/n answer.
gdb $gtm_dist/mumps >& gdb.out << GDB_EOF
set breakpoint pending on
b rel_latch
r -direct
do ^$mrtn
quit
y
GDB_EOF

echo '# Below is the gdb log (pasted to ensure the breakpoint is reached and the process is killed)'
$grep -E "Breakpoint|killed" gdb.out

echo '# Now try [do ^x] without the debugger. This should recognize the dead latch holder pid and salvage it.'
echo '# This should only take 1 second or so (not 30 seconds)'
echo '# We allow for a max of 4 seconds (in case of a loaded system etc.) but nothing more than that.'
echo '# Without the YDB#1083 fixes, the time taken has been seen to be anywhere from 30 seconds to 2 minutes.'
echo '# PASS is printed if time taken is less than 4 seconds and FAIL otherwise.'

cat > ydb1083.m << CAT_EOF
 set start=\$horolog
 do ^$mrtn
 set end=\$horolog
 set elapsed=\$\$^difftime(end,start)
 write \$select(elapsed<=4:"PASS",1:"FAIL: Max 4 seconds allowed but Actual time taken = "_elapsed_" seconds"),!
CAT_EOF

$gtm_dist/mumps -run ydb1083

