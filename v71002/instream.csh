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
# reorg_levelrestrict-gtmde549071		[jon]	Test REORG traverses the database correctly and accepts restrictions on which levels it processes
# reorgblocksplit-gtmde549072			[jon]	Test REORG successful block splitting and correct database traversal [#684][#685]
# ztimeout_microresolution-gtmde534846		[jon]	Test $ZTIMEOUT presents the time remaining value to microsecond resolution
# resbytesfillf_impossiblock-gtmde549073	[jon]	REORG no longer accepts a combination of reserved bytes and fill factor which together target an impossible block size
# mupipupgrade_maxtreedepth-gtmde556760		[jon]	Test MUPIP UPGRADE appropriately processes V6 database files that exceed the maximum tree depth (7 levels) associated with pre-V7 versions
# dollarzicuver-gtmf229760			[jon]	Test $ZICUVER provide the ICU version if available
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71002 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic reorg_levelrestrict-gtmde549071"
setenv subtest_list_non_replic	"$subtest_list_non_replic reorgblocksplit-gtmde549072"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztimeout_microresolution-gtmde534846"
setenv subtest_list_non_replic	"$subtest_list_non_replic resbytesfillf_impossiblock-gtmde549073"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupipupgrade_maxtreedepth-gtmde556760"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollarzicuver-gtmf229760"
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

echo "v71002 test DONE."
