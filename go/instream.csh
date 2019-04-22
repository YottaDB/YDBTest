#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
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
# threeenp1B1		[estess]	Drive golang version B1 of 3n+1 routine as a test/demo (embedded TP callback rtns) (goroutines)
# threeenp1B2		[estess]	Drive golang version B2 of 3n+1 routine as a test/demo (not-embedded TP callback rtns) (goroutines)
# wordfreq		[estess]	Drive golang vesion of wordfreq routine as a test/demo
# random_walk           [hathawayc]     Drive test which randomly walks Go commands
# threeenp1C2		[estess]	Drive golang version B2 of 3n+1 routine as a test/demo (not-embedded TP callback rtns) (processes)
# pseudoBank		[mmr]		Test of simulated banking transactions using Go Simple API with 10 goroutines in ONE process
#
echo "go test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "unit_tests threeenp1B1 threeenp1B2 random_walk threeenp1C2"
setenv subtest_list_non_replic "wordfreq pseudoBank"
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
