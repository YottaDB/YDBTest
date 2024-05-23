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
# view_device-gtmf157495	[berwyn] 	Test that new function $VIEW("DEVICE",<device>) retuns the specified device status
# integ_dumpfh_order-gtmf134692	[pooh]		MUPIP INTEG and MUPIP DUMPFHEAD support the user-specified region order
# postconditional-gtmde276621	[berwyn]	Verify fix for v70002 regression where false postconditional could cause segfault
# empty_loop_var-gtmf135424	[berwyn]	Empty string rather than UNDEF error when lost FOR control variable in NOUNDEF mode
# dlr_zkey_sig11-gtmde294187    [nars]          Test $ZKEY does not result in SIG-11 or heap-use-after-free error (in ASAN build)
# zsocket_sigsegv-gtmf135428 	[ern0] 		$ZSOCKET() returns an empty string when given an out of range index
# socket_opts-gtmf135169 	[ern0] 		Verify additional options for SOCKET devices
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70003 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"view_device-gtmf157495"
setenv subtest_list_non_replic	"$subtest_list_non_replic integ_dumpfh_order-gtmf134692"
setenv subtest_list_non_replic	"$subtest_list_non_replic postconditional-gtmde276621"
setenv subtest_list_non_replic	"$subtest_list_non_replic empty_loop_var-gtmf135424"
setenv subtest_list_non_replic	"$subtest_list_non_replic dlr_zkey_sig11-gtmde294187"
setenv subtest_list_non_replic	"$subtest_list_non_replic zsocket_sigsegv-gtmf135428"
setenv subtest_list_non_replic	"$subtest_list_non_replic socket_opts-gtmf135169"
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
