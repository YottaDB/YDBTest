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
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# gtm8877	[vinay] Tests the functionality of ZSYSTEM_FILTER and PIPE_FILTER
# gtm8930	[jake]  Tests the $VIEW("JNLPOOL") output for unopened/opened JNLPOOL and undefined replication instance file
# gtm5059	[jake]  Tests new gtm_mstack_crit_threshold variable for setting which percentage of the mstack memory is used before a STACKCRIT error is issued
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63005 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8877 gtm5059"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic gtm8930"


if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63005 test DONE."
