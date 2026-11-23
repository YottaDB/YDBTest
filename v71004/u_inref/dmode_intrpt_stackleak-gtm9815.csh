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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9815 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959409815)

Processes in Direct Mode handle local variables appropriately when interrupted by SIGINT or SIGUSR1 signals. Previously, processing such signals in Direct Mode leaked stack space, potentially causing STACKCRIT and/or STACKOFLOW errors. (GTM-9815)

CAT_EOF
echo

echo '# The leak happens each time a signal interrupts a process that waits for input at the Direct Mode prompt of a'
echo '# terminal. This subtest starts such a process with the smallest M stack (gtm_mstack_size=25, in KiB), and'
echo '# interrupts the process 1000 times with SIGUSR1 (what MUPIP INTRPT sends) and then 1000 times with <CTRL-C>'
echo '# (SIGINT). Each SIGUSR1 runs $ZINTERRUPT code that increments ^cnt.'
echo '# Before the fix : STACKCRIT after about 250 SIGUSR1 signals, and a fatal STACKOFLOW error in the <CTRL-C> stage.'
echo '# With the fix   : the process handles all 2000 interrupts and $ZSTATUS is empty at the end.'
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

# The leak is in the code that reads the Direct Mode prompt of a terminal without readline, so do not use readline.
unsetenv ydb_readline
unsetenv gtm_readline
setenv gtm_mstack_size 25

echo '# Run [expect dmode_intrpt_stackleak-gtm9815.exp 1000]'
# Use .outx (not .out) file names below so the test framework error scan does not pick over raw expect output
(expect -d $gtm_tst/$tst/u_inref/dmode_intrpt_stackleak-gtm9815.exp 1000 > dmode.exp.outx) >& dmode.exp.dbg
echo '# Expect no TEST-E-FAIL, STACKCRIT or STACKOFLOW in the expect output'
$grep -aE 'TEST-E-FAIL|STACKCRIT|STACKOFLOW' dmode.exp.outx | sort -u
echo '# Expect 1000 CTRLC messages in the expect output'
$grep -ac 'CTRL_C encountered' dmode.exp.outx
echo '# Expect result.txt (written by the Direct Mode process at the end) to show 1000 and an empty $ZSTATUS'
cat result.txt
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
