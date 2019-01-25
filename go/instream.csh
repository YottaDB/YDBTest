#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# unit_tests		[hathawayc]	Drive 'go test' test harness
# simpleapithreeen1f	[estess]	Drive golang version of 3n+1 routine as a test/demo
# wordfreq		[estess]	Drive golang vesion of wordfreq routine as a test/demo
# gengluecode           [hathawayc]     Drive tests which verify TP glue code generation works
# random_walk           [hathawayc]     Drive test which randomly walks Go commands
#
echo "go test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "unit_tests simpleapithreeenp1f gengluecode random_walk"
setenv subtest_list_non_replic "wordfreq"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out below subtest on 32-bit ARM since it could use memory >= 2Gb, a lot on a 32-bit process
	setenv subtest_exclude_list "$subtest_exclude_list random_walk"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "go test DONE."
