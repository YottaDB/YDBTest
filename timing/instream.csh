#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test is a placeholder for all subtests that are timing-sensitive and hence cannot be run
# while other tests are concurrently running. This is part of the M_ALL suite and hence will be
# run in standalone mode so we should not see false failures due to other tests affecting system load.

#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm8680      [vinay] (moved from "v63003" test) Tests YDB does not slow down significantly when holding a large number of locks and/or processes
# gctest       [nars]  (moved from "r120"   test) Test stringpool garbage collection performance with lots of strings in the pool
# largelvarray [nars]  (moved from "r120"   test) Test local array performance does not deteriorate exponentially with large # of nodes
# go_unit_tests [hathawayc] (copied from go/unit_tests) run unit tests with time-sensitive tests enabled
#-------------------------------------------------------------------------------------

echo "timing test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8680 gctest largelvarray go_unit_tests"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

if ("dbg" == "$tst_image") then
	# gctest subtest stresses the stringpool garbage collection and runs very slow in dbg so disable it there.
	setenv subtest_exclude_list "$subtest_exclude_list gctest"
	# go_unit_tests has timing tests that have been seen to fail with varying thresholds using dbg even on x86_64
	# boxes so disable it on all platforms. It is enough to test this with "pro".
	setenv subtest_exclude_list "$subtest_exclude_list go_unit_tests"
endif

# Disable tests that start lots of processes on ARM boxes as response times on that platform have been seen to be non-deterministic
if (("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8680"
endif

# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list largelvarray"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "timing test DONE."
