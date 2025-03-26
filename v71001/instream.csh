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
# ygblstat_cmdlinewarn-gtmde503394		[jon]	Test %YGBLSTAT issues warnings for defective command lines
# comptimelit_numoflow-gtmde50885		[jon]	Test NUMOFLOW errors correctly reported when evaluating unary operations on literals at compile time
# ztranslate_nobadchar-gtmde525624		[jon]	Test $ZTRANSLATE() does not issue a BADCHAR when operating on UTF-8 strings
# ygblstat_cmdlinewarn-gtmde503394		[jon]	Test %YGBLSTAT issues warnings for defective command lines
# numoflow_regression				[jon]	Test fix of regression resulting in assert failure instead of NUMOFLOW error
# booleansubs_sideeffects-gtmde513737		[jon]	Test the truth-value of subscripted local variables in Boolean expressions is protected from subsequent side effects
# xecuteopfail_cleancompile-gtmde510902		[jon]	Test prevent literal operation failures in XECUTE blocks from improperly affecting the surrounding execution environment
# atlongexpr_zshowvtolcl-gtmde512004		[jon]	Test SET @expr supports long exprs and %ZSHOWVTOLCL uses them for alias containers
# zmaxtptime_critinterrupt-gtmde513980		[jon]	Test $ZMAXTPTIME can interrupt a transaction holding a database critical section
# ztimeout_tpdefer-gtmde519525			[jon]	Test $ZTIMEOUT deferred during a TP transaction
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71001 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic ygblstat_cmdlinewarn-gtmde503394"
setenv subtest_list_non_replic	"$subtest_list_non_replic numoflow_regression"
setenv subtest_list_non_replic	"$subtest_list_non_replic randstr_rangearg-gtmde500856"
setenv subtest_list_non_replic	"$subtest_list_non_replic compilerext-gtmde500860"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztranslate_nobadchar-gtmde525624"
setenv subtest_list_non_replic	"$subtest_list_non_replic booleansubs_sideeffects-gtmde513737"
setenv subtest_list_non_replic	"$subtest_list_non_replic comptimelit_numoflow-gtmde508852"
setenv subtest_list_non_replic	"$subtest_list_non_replic xecuteopfail_cleancompile-gtmde510902"
setenv subtest_list_non_replic	"$subtest_list_non_replic atlongexpr_zshowvtolcl-gtmde512004"
setenv subtest_list_non_replic	"$subtest_list_non_replic zmaxtptime_critinterrupt-gtmde513980"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztimeout_tpdefer-gtmde519525"
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
