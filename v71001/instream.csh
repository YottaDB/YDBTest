#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
# ygblstat_cmdlinewarn-gtmde503394	[jon]	Test %YGBLSTAT issues warnings for defective command lines
# numoflow_regression			[jon]	Test fix of regression resulting in assert failure instead of NUMOFLOW error
# ztranslate_nobadchar-gtmde525624	[jon]	Test $ZTRANSLATE() does not issue a BADCHAR when operating on UTF-8 strings
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71001 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"ygblstat_cmdlinewarn-gtmde503394"
setenv subtest_list_non_replic	"numoflow_regression"
setenv subtest_list_non_replic	"randstr_rangearg-gtmde500856"
setenv subtest_list_non_replic	"compilerext-gtmde500860"
setenv subtest_list_non_replic	"ztranslate_nobadchar-gtmde525624"
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

echo "v71001 test DONE."
