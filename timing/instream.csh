#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	#
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
# gtm9115      [bdw]   (moved from "V63009" test) Tests that %DO, %OD, %HO and %OH do not perform worse than their pre-V6.3-009 implementations
#-------------------------------------------------------------------------------------

echo "timing test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8680 gctest largelvarray go_unit_tests gtm9115"
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
endif

# go_unit_tests has timing tests that have been seen to fail with varying thresholds using dbg even on x86_64
# boxes so disable it on all platforms. It is enough to test this with "pro". That said, in "pro", ARMV6L has been seen
# to fail this test once in a while. Even ARMV7L has been seen to fail it once in a while (but at a much lesser failure
# rate compared to ARMV6L) so disable it on both those platforms. All of the code that is being tested here for performance
# is portable and it is enough if we test it on x86_64 and AARCH64.
if (("dbg" == "$tst_image") || ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype)) then
	setenv subtest_exclude_list "$subtest_exclude_list go_unit_tests"
endif

# Disable tests that start lots of processes on ARM boxes as response times on that platform have been seen to be non-deterministic
# Also disable the performance test for base conversions on ARM boxes as it sometimes fails unless the run time is extremely long
if (("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8680 gtm9115"
endif

if ($gtm_test_singlecpu) then
	# Disable certain heavyweight tests on single-cpu systems
	setenv subtest_exclude_list "$subtest_exclude_list largelvarray"
else
	# Disable "largelvarray" subtest on AARCH64 systems running Ubuntu as this has been seen to fail intermittently there
	# with time taken going way beyond the allowed limits. AARCH64 systems running Debian 11 don't seem to have such failures.
	# Not yet sure why. Will worry about it if we start seeing failures on the Debian AARCH64 systems too.
	source $gtm_tst/com/set_gtm_machtype.csh	# to setenv "gtm_test_linux_distrib"
	if (("HOST_LINUX_AARCH64" == $gtm_test_os_machtype) && ("ubuntu" == $gtm_test_linux_distrib)) then
		setenv subtest_exclude_list "$subtest_exclude_list largelvarray"
	endif
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "timing test DONE."
