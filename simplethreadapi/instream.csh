#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-----------------------------------------------------------------------------------------------------------------------------------
# lockst	[estess]	Test the functionality of the ydb_lock_st() EP of the SimpleThreadAPI (STAPI)
#-----------------------------------------------------------------------------------------------------------------------------------

echo "simplethreadapi test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic lockst"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# filter out replication tests that use pre-V60000 versions because these versions do not have dbg builds.
if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out below test on 32-bit ARM since it relies on hash collisions which happen only on Linux x86_64 currently
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "simplethreadapi test DONE."
