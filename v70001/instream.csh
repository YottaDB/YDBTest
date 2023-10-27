#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
# gtm9213	[estess]	Verify a process can SET the trailing portion of $SYSTEM
# gtm8010	[estess]	Test that 128-255 byte EXCEPTION parm on OPEN of /dev/null operates correctly
# gtm9452	[sam,hoyt]	CLOSE deviceparameter REPLACE overwrites an existing file, which RENAME does not
# gtm8681	[estess]	Verify MUPIP BACKUP -RECORD stores the time of its start when it completes successfully
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70001 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"gtm9213 gtm8010 gtm9452 gtm8681"
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

echo "v70001 test DONE."
