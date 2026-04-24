#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
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
# qlength_qsubscript_support_hasht_gbl-ydb982	[david]	Test $qlength()/$qsubscript() support of ^#t internal trigger global
# illegal_nakedglobalref-ydb1223		[jon]	Test fix for illegal naked global reference in release r2.04
# iottflush_assertfix-ydbmr1854			[jon]	Test iott_flush() assert fixes in YDB!1854
#----------------------------------------------------------------------------------------------------------------------------------

echo "r206 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic qlength_qsubscript_support_hasht_gbl-ydb982"
setenv subtest_list_non_replic	"$subtest_list_non_replic illegal_nakedglobalref-ydb1223"
setenv subtest_list_non_replic	"$subtest_list_non_replic iottflush_assertfix-ydbmr1854"
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

echo "r206 test DONE."
