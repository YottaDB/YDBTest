#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# view_device-gtmf157495	[berwyn]	Test that new function $VIEW("DEVICE",<device>) retuns the specified device status
# integ_dumpfh_order-gtmf134692	[pooh]		MUPIP INTEG and MUPIP DUMPFHEAD support the user-specified region order
# zsocket_sigsegv-gtmf135428 	[ern0] 		$ZSOCKET() returns an empty string when given an out of range index
# postconditional-gtmde276621	[berwyn]	Verify fix for v70002 regression where false postconditional could cause segfault
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70003 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"view_device-gtmf157495 integ_dumpfh_order-gtmf134692 zsocket_sigsegv-gtmf135428"
setenv subtest_list_non_replic	"$subtest_list_non_replic postconditional-gtmde276621"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70003 test DONE."
