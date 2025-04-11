#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
# mupipstop_readlineterm-ydb1128	[jon]	Test MUPIP STOP terminates DSE/LKE/MUPIP even if they hold a critical section when ydb_readline=1
# mureorgupgrade-ydb1027		[jon]	Test 2 MUPIP REORG -UPGRADE test cases for YDB#1027
#----------------------------------------------------------------------------------------------------------------------------------

echo "r204 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic view_statshare-ydb254"
setenv subtest_list_non_replic	"$subtest_list_non_replic zshow_v-ydb873"
setenv subtest_list_non_replic	"$subtest_list_non_replic gtm-v71001"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollar_translate-ydb1129"
setenv subtest_list_non_replic	"$subtest_list_non_replic machine-ydb1133"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollar_zycompile-ydb1138"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupipstop_readlineterm-ydb1128"
setenv subtest_list_non_replic	"$subtest_list_non_replic mureorgupgrade-ydb1027"
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

echo "r204 test DONE."
