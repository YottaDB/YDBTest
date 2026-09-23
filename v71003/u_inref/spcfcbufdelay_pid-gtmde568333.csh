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
GTM-DE568333 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE568333)

GT.M messages SPCFCBUFDELAY and WRITERSTUCK include the process ID (PID) of the block resource holder. Note: GT.M WRITERSTUCK messages repeat for each block resource held. Previously, BUFSPCDELAY and WRITERSTUCK did not include the PID of the block resource holder. (GTM-DE568333)

CAT_EOF
echo

# The WRITERSTUCK half of this release note is covered by v54000/C9D08002390 (test case 1 covers the PID,
# test case 4 covers the repeat-per-writer behavior). This subtest covers the SPCFCBUFDELAY half.
#
# Reaching SPCFCBUFDELAY on a stock build is impractical. "wcs_get_space" only issues it every
# UNIX_GETSPACEWAIT (12000) iterations of its wait loop, which is roughly two minutes of "wcs_sleep" before
# the first message, and only while a specific cache record stays dirty for that whole period. White box test
# case 410 (WBTEST_FORCE_SPCFCBUFDELAY) drops "lcnt" straight onto the reporting interval so the message is
# issued promptly. This mirrors how white box test case 25 (WBTEST_BUFOWNERSTUCK_STACK) makes WRITERSTUCK
# reachable in v54000/C9D08002390.
#
# The scheme is:
#   1. Create a BG database, without ASYNCIO, with a small global buffer cache so cache records get recycled
#      aggressively. See the comments against acc_meth and gtm_test_asyncio below for why both are forced.
#   2. Start a "holder" process under white box test case 143 (WBTEST_DB_WRITE_HANG), which sleeps inside
#      DB_LSEEKWRITE while still owning the cache record it was writing. That leaves "cr->epid" set to the
#      holder's PID and "cr->dirty" set, which is the state SPCFCBUFDELAY reports.
#   3. Start a "delayed" process under white box test case 410 (WBTEST_FORCE_SPCFCBUFDELAY), churning the
#      cache until "db_csh_getn" recycles the holder's cache record and so calls
#      "wcs_get_space(reg, 0, cr)". Case 410 also makes "db_csh_getn" take dirty cache records on its first
#      pass over the cache. Without that it only reaches "wcs_get_space" after a whole pass has failed to
#      find a clean record, which depends on out-writing the flusher and made this subtest fail
#      intermittently.
#   4. Check the operator log for SPCFCBUFDELAY and confirm the PID it names is the holder's.
#
# Note on runtime: the delayed process cannot get past "wcs_get_space" until the holder comes out of its hang,
# so the length of that hang sets the floor on how long this subtest takes. WBTEST_DB_WRITE_HANG hangs for a
# fixed 3 minutes unless ydb_white_box_test_case_count says otherwise, so the holder below sets it to
# $holderhang seconds. Do not raise it without reason.

# This subtest is inherently BG-only: the "wait for a specific buffer" branch of "wcs_get_space" that issues
# SPCFCBUFDELAY only exists because BG has a global buffer cache to contend for. MM never goes near it. Force
# BG via acc_meth (see com/dbcreate_base.csh).
setenv acc_meth BG

# This subtest also needs synchronous database writes. The holder process is pinned to its cache record by
# WBTEST_DB_WRITE_HANG, which only fires from DO_LSEEKWRITE in sr_port/anticipatory_freeze.h. With ASYNCIO on
# the segment, "wcs_wtstart" writes global buffers through DB_LSEEKWRITEASYNC -> DO_LSEEKWRITEASYNC instead,
# and that macro has no HANG hook at all, so the holder never hangs and no buffer is ever held dirty.
#
# ASYNCIO would make the message harder to reach in any case: with it on, "wcs_get_space" can return FALSE out
# of WAIT_FOR_WIP_QUEUE_TO_CLEAR before it ever enters the wait loop that issues SPCFCBUFDELAY.
setenv gtm_test_asyncio 0

echo "# Create a BG database with a small global buffer cache"
$gtm_tst/com/dbcreate.csh mumps -global_buffer_count=64 >& dbcreate.out
if (0 != $status) then
	echo "TEST-E-FAIL dbcreate.csh failed. Output follows"
	cat dbcreate.out
	exit 1
endif

cp $gtm_tst/$tst/inref/gtmde568333.m .

set syslog_before = `date +"%b %e %H:%M:%S"`
echo "# Time before test : GTM_TEST_DEBUGINFO $syslog_before"

echo "# Start the holder process, which hangs inside a database write still owning a dirty cache record"
# For WBTEST_DB_WRITE_HANG the count is the hang duration in seconds. It has to be comfortably longer than it
# takes the delayed process to start, churn the cache onto the holder's record and then spin far enough around
# the "wcs_get_space" wait loop to issue the first SPCFCBUFDELAY, but every second beyond that is dead time.
set holderhang = 60
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 143	# WBTEST_DB_WRITE_HANG
setenv gtm_white_box_test_case_count $holderhang
($gtm_dist/mumps -run holder^gtmde568333 >&! holder.outx &) >&! holder.log

# The holder announces itself to the syslog with TEST-I-LSEEKWRITEHANGSTART (see "lseekwrite_hang_sleep" in
# sr_port/anticipatory_freeze.h) once it is actually hung. Wait for that rather than guessing at a sleep,
# because starting the delayed process before the holder is wedged would simply not produce the message.
# getoper.csh waits for the message named in its 5th argument, so no polling loop is needed here.
echo "# Wait for the holder to reach the hang"
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog_hang.txt "" LSEEKWRITEHANGSTART >& getoper_hang.log
$grep -q "LSEEKWRITEHANGSTART" syslog_hang.txt
if (0 != $status) then
	echo "TEST-E-FAIL holder process did not reach the database write hang"
	exit 1
endif

set holderpid = `cat holder.pid`
echo "# Holder process is hung : GTM_TEST_DEBUGINFO holder PID $holderpid"

echo "# Start the delayed process, which has to wait on the cache record the holder owns"
setenv gtm_white_box_test_case_number 410	# WBTEST_FORCE_SPCFCBUFDELAY
# The white box macro resets its own counter each time it fires, so this is the number of "wcs_get_space"
# wait-loop iterations between successive SPCFCBUFDELAY messages. Each iteration sleeps up to 10ms, so this is
# very roughly one message every 2.5 seconds. It needs to be small enough that the first message comfortably
# beats the holder's $holderhang second hang, and large enough not to flood the syslog across that window.
# This and $holderhang are the two tuning knobs of this subtest.
setenv gtm_white_box_test_case_count 250
$gtm_dist/mumps -run delayed^gtmde568333 >&! delayed.out
unsetenv gtm_white_box_test_case_enable

echo "# Check the operator log for the message YDB-W-SPCFCBUFDELAY"
# getoper.csh polls for up to 300 seconds before giving up, so check explicitly and bail out rather than
# falling through into another long wait below in case the message never showed up.
# Every grep of the syslog below is narrowed to this test's own database file, since a SPCFCBUFDELAY issued by
# another subtest running on the same host would otherwise add a line to the reference output and a second PID
# to $spcfcpid. v54000/C9D08002390 narrows its syslog greps the same way, by the DSE PID.
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog.txt "" "SPCFCBUFDELAY.*$PWD/mumps.dat"
$grep "YDB-W-SPCFCBUFDELAY" syslog.txt | $grep -q "$PWD/mumps.dat"
if (0 != $status) then
	echo "TEST-E-FAIL no SPCFCBUFDELAY message was issued. The delayed process likely never had to wait on"
	echo "TEST-E-FAIL the cache record the holder owned. Check holder.outx, delayed.out and syslog.txt."
	$gtm_dist/mupip stop $holderpid >& mupip_stop.out
	exit 1
endif

# The block number and PID vary from run to run, so normalize them for the reference file. Several messages
# are expected (one per gtm_white_box_test_case_count iterations), so reduce them to the distinct set.
$grep "YDB-W-SPCFCBUFDELAY" syslog.txt | $grep "$PWD/mumps.dat" \
	| sed 's/.*\(YDB-W-SPCFCBUFDELAY\)/\1/; s/block 0x[0-9A-Fa-f]*/block 0xBLOCKNUMBER/; s/delayed by PID [0-9][0-9]*/delayed by PID PIDNUMBER/' \
	| sort -u

# The point of the release note is the PID, so check it explicitly rather than leaving it normalized away.
set spcfcpid = `$grep "YDB-W-SPCFCBUFDELAY" syslog.txt | $grep "$PWD/mumps.dat" | sed 's/.*delayed by PID //; s/[^0-9].*//' | sort -u`
if ("$spcfcpid" == "$holderpid") then
	echo "# SPCFCBUFDELAY correctly named the PID of the process holding the block resource"
else
	echo "TEST-E-FAIL SPCFCBUFDELAY named PID '$spcfcpid' but the block resource holder is PID '$holderpid'"
endif

echo "# Stop the holder process"
# The holder defers interrupts for the duration of "wcs_wtstart", so a MUPIP STOP issued while it is still in
# its hang is not acted on until it comes out the far side. By this point the delayed process has run to
# completion, which means the hang has already ended, so the stop is acted on promptly. The holder may also
# have finished its own loop and exited already, in which case MUPIP STOP says so in mupip_stop.out.
$gtm_dist/mupip stop $holderpid >& mupip_stop.out
$gtm_tst/com/wait_for_proc_to_die.csh $holderpid 120 >& wait_for_holder.log

$gtm_tst/com/dbcheck.csh >& dbcheck.out
