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
GTM-10554 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410554)

GT.M includes six additional counters tracking milliseconds of time slept while waiting on another process to finish a task. The counters are available as part of all forms of GVSTATs, and have the following mnemonics and descriptions:

JCS - milliseconds of time slept in crit waiting for another process to finish a write into the journal file.
JNS - milliseconds of time slept outside of crit waiting for another process to finish a write into the journal file.
WPCS - milliseconds of time slept in crit waiting for another process to finish flushing a block to disk.
RCS - milliseconds of time slept in crit waiting for another process to finish reading in a block from disk.
WFCS - milliseconds of time slept in crit while performing a flush of one or more blocks to disk, usually in an epoch.
GCS - milliseconds of time slept in crit while acquiring a global buffer and waiting for another process to finish writing a block to disk.

These counters can help identify the cause of performance degradation. High values per second can indicate I/O throughput issues that are forcing GT.M to perform excessive coordination activity. (GTM-10554)

CAT_EOF
echo

echo '# A counter increases only while a process sleeps because another process is in the middle of a write or a read.'
echo '# So each stage starts a "holder" process with a white-box test case that makes the holder sleep for 10 seconds'
echo '# in the middle of a write (142 = WBTEST_JNL_WRITE_HANG for the journal file, 143 = WBTEST_DB_WRITE_HANG for'
echo '# the database file), and then runs a "waiter" that needs what the holder owns. The waiter has to sleep until'
echo '# the holder is done, so the counter of that kind of sleep has to be 1000 (milliseconds) or more afterwards.'
echo '# This subtest covers JNS, JCS, WPCS and WFCS. RCS and GCS are not covered as there is no white-box test case'
echo '# that makes a process sleep in the middle of a block read, or between the end of a block write and the'
echo '# release of the global buffer.'
echo

# The white-box test cases used below are in the code path of synchronous writes to a BG database file.
setenv acc_meth BG
setenv gtm_test_asyncio 0
# Journaling is turned on below (the same way for every run) so do not let the test framework turn journaling on.
setenv gtm_test_jnl NON_SETJNL
# Each white-box test case makes a process sleep at a fixed count of writes (to the journal file or to the database
# file) since the shared memory of the database was created. Each stage relies on that count starting from zero,
# that is, on the shared memory being removed when the last process of the previous stage exits. With a 16K counter
# semaphore bump per process, the 32K counter overflow happens with just 2 processes, and the shared memory is then
# left around. So disable counter overflows.
unsetenv gtm_db_counter_sem_incr
set holdersleep = 10

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
$MUPIP set -journal=enable,on,nobefore -region DEFAULT >& jnl_on.out

# start_holder <entryref> <white-box test case number> : starts the holder and waits until the holder sleeps
alias start_holder 'setenv gtm_white_box_test_case_enable 1; setenv gtm_white_box_test_case_number \!:2;	\\
	setenv gtm_white_box_test_case_count $holdersleep;							\\
	rm -f holder.pid;											\\
	($gtm_dist/mumps -run \!:1^gtm10554 >>& holder.outx &) >& holder.log;					\\
	unsetenv gtm_white_box_test_case_enable; unsetenv gtm_white_box_test_case_number;			\\
	unsetenv gtm_white_box_test_case_count;									\\
	$gtm_dist/mumps -run waithang^gtm10554'
# stop_holder : stops the holder (which also removes the shared memory of the database, so that the write
# counters that the white-box test cases use start from zero again in the next stage)
alias stop_holder '$MUPIP stop `cat holder.pid` >>& mupip_stop.out;						\\
	$gtm_tst/com/wait_for_proc_to_die.csh `cat holder.pid` 120 >>& wait_for_holder.log;			\\
	$gtm_dist/mumps -run %XCMD "kill ^holder,^waiter,^progress"'

echo '# Stage 1 : JNS. The holder sleeps in a write to the journal file (outside crit).'
echo '# The waiter commits a TP transaction, which hardens the journal file after crit is released.'
start_holder holderjnl 142
$gtm_dist/mumps -run jns^gtm10554
stop_holder
echo

echo '# Stage 2 : JCS. The holder sleeps in a write to the journal file (outside crit).'
echo '# The waiter runs VIEW "JNLFLUSH", which writes the journal buffer to the journal file while holding crit.'
start_holder holderjnl 142
$gtm_dist/mumps -run jcs^gtm10554
stop_holder
echo

echo '# Stage 3 : WPCS. The holder sleeps in a write of a global buffer to the database file.'
echo '# The waiter updates every node that the holder has set, so one of the updates needs that global buffer.'
start_holder holderdb 143
$gtm_dist/mumps -run wpcs^gtm10554
stop_holder
echo

echo '# Stage 4 : WFCS. The holder sleeps in a write of a global buffer to the database file.'
echo '# The waiter is DSE BUFFER_FLUSH, which waits in crit for processes that are writing global buffers.'
echo '# DSE is a separate process, so this stage uses the counter that all processes share, from $VIEW("GVSTATS").'
start_holder holderdb 143
set before = `$gtm_dist/mumps -run %XCMD 'do shared^gtm10554("WFCS")'`
$DSE buffer_flush >& dse_buffer_flush.out
set after = `$gtm_dist/mumps -run %XCMD 'do shared^gtm10554("WFCS")'`
$gtm_dist/mumps -run %XCMD 'do check^gtm10554("WFCS increase","'"$after"'"-"'"$before"'")'
stop_holder
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
