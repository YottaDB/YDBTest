#!/usr/local/bin/tcsh -f

#################################################################
#								#
# Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm9142               [mw]            Test that MUPIP REORG recognizes the -NOCOALESCE, -NOSPLIT and -NOSWAP qualifiers
# gtm8203               [mw]            Test to show that MUPIP REORG -TRUNCATE now supports -KEEP
# gtm9145               [mw]            Test that the code line length has been increased for ^%RI and ^%RO
# gtm8901		[mw]		Test the new quailfer -GVPATFILE for MUPIP JOURNAL -EXTRACT can extract patterns from a file
# gtm8706		[mw]		Test the new qualifer -STOPRECEIVERFILTER in MUPIP REPLICATE -RECEIVER
# gtm9155		[bdw]		Tests that certain nested selects and extrinsics work correctly
# gtm9037		[bdw]		Tests that an error message is printed to syslog if journaling is shut down due to disk or permissions error.
# gtm9037replic		[bdw]		Tests that an error message is printed to syslog if a replication instance is frozen due to to disk or permissions error.
# gtm9144		[kz]		Test that loading a binary extract into a database with different null subscript collation type produces a DBDUPNULCOL error
# gtm9134               [kz]            Tests that when a replication Receiver Server waiting for a connection detects bad input, it resets the connection
# gtm9123		[kz] 		Tests that GT.M produces a correct result with gtm_side_effect set to one or two
# gtm9115		[bdw]		Tests %HO, %OH, %DO and %OD for correctness and for performance improvement compared to pre V6.3-009 versions
#----------------------------------------------------------------------------------------------------------------------------------------------------------------


echo "v63009 test starts..."

# List the subtests seperated by sspaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9142 gtm8203 gtm9145 gtm8901 gtm8706 gtm9155 gtm9037 gtm9144 gtm9123 gtm9115"
setenv subtest_list_replic	"gtm9037replic gtm9134"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
if("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63009 test DONE."
