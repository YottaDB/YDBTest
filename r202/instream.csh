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
# rlsiglongjmp-ydb1065		[sam]	Multiple signals to a process in readline mode causes loss of stack
# mupip_verbose-ydb1060		[pooh]	Test functionality of MUPIP BACKUP, MUPIP FREEZE and MUPIP INTEG with option -DBG and -VERBOSE
# zshow_tt_host_conv-ydb1068	[pooh]	Test ZSHOW "D" output for TTSYNC, NOTTSYNC, HOSTSYNC, NOHOSTSYNC, CONVERT and NOCONVERT
# empty_socket_assert-ydb1076	[pooh]	Test if empty host string in socket connection parameter causing assertion failure
# xcretnull-ydb1007		[berwyn] Ensure that external calls that return invalid values produce errors
#----------------------------------------------------------------------------------------------------------------------------------

echo "r202 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"rlsiglongjmp-ydb1065 mupip_verbose-ydb1060 zshow_tt_host_conv-ydb1068"
setenv subtest_list_non_replic	"$subtest_list_non_replic empty_socket_assert-ydb1076 xcretnull-ydb1007"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# Disable the below subtest because it is a white-box test.
	setenv subtest_exclude_list "$subtest_exclude_list rlsiglongjmp-ydb1065"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r202 test DONE."
