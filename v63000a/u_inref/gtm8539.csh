#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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


source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

$gtm_tst/com/dbcreate.csh mumps

$MUPIP set -journal="enable,on,before,auto=208896,epoch_interval=300" -reg "*" >& mupip_set_jnl.log

echo "# Run test routine [gtm8539.m]"
set start_time = `date +%s`
$gtm_dist/mumps -run gtm8539 >& gtm8539.out
set end_time = `date +%s`
@ elapsed = $end_time - $start_time

echo "# Get total DFS"
$DSE d -f -a >&! dse_after.out
set dfs = `$grep DFS dse_after.out | sed 's/^.*0x//'`
set dfs = `$gtm_tst/com/radixconvert.csh h2d $dfs | awk '{print $NF}'`

echo "## Compute acceptable number of FSYNCs based on elapsed time to account for additional FSYNCs"
echo "# [YDBTest#988] Database fsyncs here scale with how long the test takes to run, not just with the fixed amount of work it"
echo "# does (5,000,000 iterations), because YDB's periodic write cache flush activity is time-driven. Under system"
echo "# load this loop can take much longer than normal, producing more fsyncs without indicating any actual defect."
echo "# So, allow additional fsyncs proportional to any runtime beyond a generous ceiling, instead of limiting fsyncs"
echo "# to a single fixed bound."
set normal_duration = 150	# Seconds
@ excess = $elapsed - $normal_duration
# If routine finishes faster than expected, report no extra time has passed (instead of negative value)
if ($excess < 0) set excess = 0
# Baseline of 15 matches the original (pre-#988) fixed bound, so a normal-speed run (elapsed <= normal_duration)
# behaves exactly as before. Accept 1 extra FSync per 300 seconds (the same value as epoch_interval above) beyond
# that. Calibrated against 10 passing runs (all ~100s, 4-7 fsyncs) on a non-loaded system and 2 failing runs on a
# loaded system (2590s/2714s, both 21 fsyncs): those 2 failing cases only strictly required 1 extra fsync per
# ~407 to ~427 seconds to be covered, so 300 leaves comfortable margin (23 allowed vs. 21 observed in both cases).
@ maxdfs = 15 + ($excess / 300)

echo "# Check total DFS against max allowed DFS"
if ("" != $dfs) then
	if ($dfs <= $maxdfs) then
		echo "PASS: # of Database FSyncs was $dfs, within the expected bound of $maxdfs for a $elapsed second run"
	else
		echo "FAIL: # of Database FSyncs was $dfs, exceeding the expected bound of $maxdfs for a $elapsed second run"
	endif
else
	echo "FAIL: No DFS line in DSE output. Check whether MUMPS process prematurely terminated"
endif

$gtm_tst/com/dbcheck.csh
