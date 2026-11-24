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
GTM-9141 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959409141)

A Source Server more reliably returns memory used to manage journal files to the operating system as it moves from older to newer journal files for a region. The Source Server uses the mmap() and munmap() services rather than malloc() and free(), which may affect the memory limits for the process or the system. Previously, the Source Server deallocated memory for older journal files, but malloc() and free() rely on a system heap implementation that can interfere with attempts to return memory from the process to the operating system. (GTM-9141)

CAT_EOF
echo

echo '# The Source Server allocates buffers (of the ALIGNSIZE, 8 MiB here) for each journal file that the Source'
echo '# Server reads, and releases the buffers of a journal file when done with that file. This subtest makes the Source'
echo '# Server read a backlog of about 400 MiB from more than 20 journal files, and checks, from VmRSS and VmHWM (the'
echo '# peak of VmRSS) in /proc/<pid>/status of the Source Server, that'
echo '#   1. the memory of the Source Server grew by 40 MiB or more while the Source Server read the backlog, and'
echo '#   2. after the backlog is cleared, the Source Server keeps less than 15% of that growth.'
echo

setenv gtm_test_jnl SETJNL
# The smallest journal pool, so that the Source Server has to read the backlog from the journal files
setenv tst_buffsize 1048576
# An ALIGNSIZE of 8 MiB and not the default of 2 MiB, because with 2 MiB a build that releases the buffers with free()
# also gives back most of the memory, so that the 15% check below cannot tell the two apart. AUTOSWITCHLIMIT is twice
# the ALIGNSIZE (16 MiB), so that the backlog is in many journal files.
setenv tst_jnl_str "$tst_jnl_str,alignsize=16384,autoswitchlimit=32768,allocation=2048,extension=2048"

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 1 -record_size=1100 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Start the Source Server only (no Receiver Server yet)'
$MSR STARTSRC INST1 INST2 RP >& startsrc.out
$MUPIP replic -source -checkhealth >& checkhealth.out
set srcpid = `$tst_awk '/PID/ {print $2; exit}' checkhealth.out`
set rss_start = `$tst_awk '/VmRSS/ {print $2}' /proc/$srcpid/status`

echo '# Do 400000 updates of 1000 bytes each, which the Source Server cannot send yet'
$gtm_dist/mumps -run %XCMD 'for i=1:1:400000 set ^a(i)=$justify(i,1000)'
@ jnlfiles = `ls mumps.mjl* | wc -l`
echo "GTM_TEST_DEBUGINFO : number of journal files = $jnlfiles" >& debuginfo.txt
if (20 <= $jnlfiles) then
	echo "# Number of journal files is 20 or more : PASS"
else
	echo "# Number of journal files is 20 or more : FAIL [$jnlfiles]"
endif

echo '# Start the Receiver Server and wait for the backlog to clear'
$MSR STARTRCV INST1 INST2 >& startrcv.out
$MSR SYNC INST1 INST2 >& sync.out
set rss_end = `$tst_awk '/VmRSS/ {print $2}' /proc/$srcpid/status`
set rss_peak = `$tst_awk '/VmHWM/ {print $2}' /proc/$srcpid/status`
@ growth_peak = $rss_peak - $rss_start
@ growth_end = $rss_end - $rss_start
echo "GTM_TEST_DEBUGINFO : Source Server pid $srcpid VmRSS at start = $rss_start kB, VmHWM = $rss_peak kB, VmRSS at end = $rss_end kB" >>& debuginfo.txt

if (40960 <= $growth_peak) then
	echo "# Memory of the Source Server grew by 40 MiB or more while reading the backlog : PASS"
else
	echo "# Memory of the Source Server grew by 40 MiB or more while reading the backlog : FAIL [$growth_peak kB]"
endif
@ growth_end_x100 = $growth_end * 100
@ growth_peak_x15 = $growth_peak * 15
if ($growth_end_x100 < $growth_peak_x15) then
	echo "# Source Server keeps less than 15% of that growth : PASS"
else
	echo "# Source Server keeps less than 15% of that growth : FAIL [$growth_end kB left of $growth_peak kB]"
endif
echo

$gtm_tst/com/dbcheck.csh -extract >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
