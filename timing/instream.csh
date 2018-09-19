#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
# gtm8680  [vinay]  (moved from "v63003" test) Tests YDB does not slow down significantly when holding a large number of locks and/or processes
# gctest   [nars]   (moved from "r120"   test) Test stringpool garbage collection performance with lots of strings in the pool
#-------------------------------------------------------------------------------------
echo "timing test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8680 gctest"
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

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "timing test DONE."
