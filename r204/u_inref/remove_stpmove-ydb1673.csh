#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
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
YDB!1673 - Test the following MR description and comment
********************************************************************************************

MR description:

* See [!1673 (comment 2462916267)](https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1673#note_2462916267) for more details.

* As seen there, the performance benefit is noticeable when 100s of copies of the same routine are linked in the same process.

* But in practice, it is not expected that someone will link more than even a dozen copies of the same routine and so this is not likely to affect anyone in practice.

* Hence not creating a YDB issue for this change.

!1673 comment 2462916267:

This is something I noticed as part of working on !1668. While trying to understand when stp_move() is called, I noticed a LOT of calls to it when the same routine name is zlinked multiple times in the same process.

The below simple test case is based on YDBTest/longname/inref/litlab.m. The test creates 1000 copies of test.m and ZLINKs them one by one in the same process.

From GT.M V6.3-007 onwards, the zlink was changed to invoke stp_move() for each of the older zlinked routines of test.m. So as we zlink the 500th copy of this routine, we will invoke stp_move() 500 times, 1 each for the older zlinked copy of this same routine. And by the time we zlink the 1000th copy of this routine, we will invoke stp_move() 1000 times.

So the time taken to zlink increases (O(N**2) algorithm) as the number of iterations increases as can be seen in the output below.

And all of this is unnecessary in my opinion (reasoning is included in a comment in the code). So the commit disables the stp_move() call. After the changes in !1673 (merged) the time taken is a constant irrespective of the number of times the routine is zlinked as can be seen below.

CAT_EOF
echo

# Disable storage debugging as that have been seen to cause runtime slowdowns that may cause this performance test to fail
unsetenv gtmdbglvl

echo "# Run litlab^ydb1673 routine to:"
echo "# 1. Create 1000 copies of test.m"
echo "# 2. ZLINK them one by one in the same process"
echo "# 3. Record the time elapsed for each 100 linkages."
# Run the test up to 3 times in case it fails due to timing issues caused by factors
# outside the test, e.g. system load, more if the system looks loaded (see below).
# See discussion at: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2668#note_3291245899
#
# If a failing iteration coincides with the system looking oversubscribed (1-min load average
# more than 3x the CPU count), that's likely why it's slow rather than a real regression, so
# keep retrying with a growing backoff instead of giving up after 3 quick attempts. The backoff
# is bounded by wall-clock time (not retry count) since what matters is outlasting whatever else
# is loading the system, e.g. stress/concurr_small has been observed to run for close to 7
# minutes on an affected host; 20 minutes gives that some margin. An idle/normal-load machine is
# unaffected by any of this and still only gets the original 3 quick attempts.
set ncpu = `nproc`
set max_try = 3
set try = 0
set start_time = `date +%s`
set overload_time_budget = 1200		# 20 min: covers stress/concurr_small's observed 10+ min runtime, plus margin
set sleep_time = 5
while ($try < $max_try)
	@ try = $try + 1
	$gtm_dist/mumps -run litlab^ydb1673 >&! try${try}.out
	grep -q  "Elapsed time = [2-9]" try${try}.out
	if (0 != $status) then
		# Only check for a PASS if the time for each round of 100 iterations
		# was within bounds, i.e. less than 2 seconds. Ideally, each round would take
		# less than 1 second, but on slow and loaded systems this may not be true,
		# even when all rounds fall within the accepted standard deviation and thus
		# demonstrate that the fix under test is working as expected.
		grep -q PASS try${try}.out
		if ($status == 0) break
	endif
	# This attempt failed (either a slow block or a stdev-only failure). If the
	# system looks oversubscribed, retry with a growing backoff.
	set is_overloaded = 0
	if (-r /proc/loadavg) then
		set is_overloaded = `$tst_awk -v ncpu=$ncpu '{print ($1 > 3*ncpu) ? 1 : 0}' /proc/loadavg`
	endif
	if (1 == $is_overloaded) then
		set elapsed = `date +%s`
		@ elapsed = $elapsed - $start_time
		if ($elapsed < $overload_time_budget) then
			@ max_try = $max_try + 1	# keep extending one attempt at a time
			sleep $sleep_time
			if ($sleep_time < 30) @ sleep_time = $sleep_time + 5
		endif
	endif
end
cat try${try}.out
