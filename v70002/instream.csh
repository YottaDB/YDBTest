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
# backup_order-gtmf135842	[pooh]		MUPIP BACKUP supports user specified order
# load_binary-gtmde201381	[pooh]		MUPIP LOAD -FORMAT=BINARY uses only data length in checking for maximum length
# zchar_length-gtmde201378	[pooh]		Prevent $[Z]CHAR() representions from generating results longer than the maximum string length
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70002 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"backup_order-gtmf135842 load_binary-gtmde20138 zchar_length-gtmde201378"
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

echo "v70002 test DONE."
