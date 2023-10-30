#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
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
#-------------------------------------------------------------------------------------
# gtm9093               [bdw]           Test of $translate that runs random inputs for 15 seconds checking for sig11s
# gtm9079               [bdw]           Tests zcompile within nested xecute for correct error code
# gtm9000               [mw]       	Test for optional fourth parameter in PEEKBYNAME
# gtm9110		[mw]		Test for the CLIERR or CLISTRTOOLONG error for a command line exceeding 32KiB
# gtm9092		[mw]		Tests for the return value of TRUE(1) or FALSE(0) in $$IN^%YGBLSTAT
# gtm9082		[mw]		Test that verifies flush_trigger_top is upgraded automatically
# gtm9098		[mw]		Test showing that MUPIP JOURNAL reports a 64bit sequence number in continuity check failure
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63008 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm9093 gtm9079 gtm9000 gtm9110 gtm9092 gtm9082 gtm9098"
setenv subtest_list_replic     ""


if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
endif
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9082"
else if (("suse" == $gtm_test_linux_distrib) || $gtm_test_ubuntu_2310_plus) then
	# Disable gtm9082 subtest on SUSE Linux and Ubuntu 23.10 (and above) as we don't have the needed
	# old versions on that distribution (due to no libtinfo.so.5 package)
	setenv subtest_exclude_list "$subtest_exclude_list gtm9082"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63008 test DONE."
