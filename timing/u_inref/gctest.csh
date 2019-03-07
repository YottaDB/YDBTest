#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that local array performance does not deteriorate exponentially with large # of nodes
# We first run the test with a small number of nodes.
# Then double it and expect the test to run approximately twice as long.
#	We allow the test to run 3 times as long. Anything longer is considered a failure.
# We double it once more and do the same time verification.
# If stpg_sort algorithm is O(n^2), the time taken for double the input size would be 4x.
# Having the threshold as 2.5x, we expect to catch the O(n^2) algorithm in stpg_sort.
# With a O(nlogn) algorithm in stpg_sort, we expect almost linear growth (i.e. 2x to 2.5x output for 2x input).
#

foreach value (10000 20000 40000 80000)
	(time $gtm_dist/mumps -run gctest $value >& $value.out ) >& time.$value
	set curcpu = `awk -Fu '{print $1}' time.$value`
	echo $curcpu >>! curcpu.txt
end

echo "Check that as array size doubled, user time increased approximately linearly"
$gtm_dist/mumps -run check^gctest curcpu.txt
