#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
$gtm_dist/mumps -run litlab^ydb1673
