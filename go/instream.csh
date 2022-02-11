#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
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
# randomWalk		[hathawayc, mmr]     Drive test which randomly walks Go EasyAPI commands
# threeenp1C2		[estess]	Drive golang version B2 of 3n+1 routine as a test/demo (not-embedded TP callback rtns) (processes)
# pseudoBank		[mmr]		Test of simulated banking transactions using Go Simple API with 10 goroutines in ONE process
# CallMTRetLen		[mmr]		Test of CallMT() and CallMDescT() functions in Go Simple API
# randomWalkSimple	[mmr]     	Drive test which randomly walks Go SimpleAPI commands
# fatal_signal		[mmr, estess]	(was sigterm) Check that random SIGTERM/SIGINT (15/2) cleanly shuts down YDBGo process with
# 			      		no cores.
# tptimeout		[estess]	Test that tptimeout works with Go
# sigsegv		[@zapkub, estess] Add test that initializes YDB, then generates a SIGSEGV and see if can be caught
# tprestart		[user, estess] 	Check that restart in a transaction whether in M or in simpleAPI returns the same way
# deadlock		[user, estess]	Test that purposely creates a deadlock situation to verify code does not let engine lock acquire
# 			       		requests run when they shouldn't.
# ydbgo34               [estess]        Test yottadb.RegisterSignalHandler() and yottadb.UnRegisterSignalHandler() functions.
# ydbgo37		[@inetstar, estess]	Verify that yottadb.Exit() takes less than 5 seconds to exit (no hang!)
#
echo "go test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "unit_tests threeenp1B1 threeenp1B2 randomWalk randomWalkSimple threeenp1C2"
setenv subtest_list_non_replic "wordfreq pseudoBank CallMTRetLen fatal_signal tptimeout sigsegv tprestart deadlock ydbgo34 ydbgo37"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# filter out test that needs to run pro-only - temp allow dbg while not allowing cores [TODO] - waiting for YDB#790 to be done
# to reactivate this portion of the code.
#if ("pro" != "$tst_image") then
#       setenv subtest_exclude_list "$subtest_exclude_list ydbgo34" # ydbgo34 generates cores and stops in dbg, continues in pro
#endif

if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out below subtest on 32-bit ARM since it could use memory >= 2Gb, a lot on a 32-bit process
	setenv subtest_exclude_list "$subtest_exclude_list randomWalk randomWalkSimple"
endif

if ($gtm_test_singlecpu) then
	# disable the random walk tests on single core systems due to use of cgo in YDBGo (which creates 1 thread per goroutine)
	setenv subtest_exclude_list "$subtest_exclude_list randomWalk randomWalkSimple"
endif

if ($gtm_test_singlecpu || ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
	# disable the ydbgo37 (timing) test on ARM or single CPU systems where timings are notoriously variable
	setenv subtest_exclude_list "$subtest_exclude_list ydbgo37"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "go test DONE."
