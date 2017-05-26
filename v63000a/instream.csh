#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# gtm8523 [nars]	SIG-11 in GT.M in a TP transaction on an MM database with concurrent file extensions
# gtm8454 [rog]		Verify ZWRITE after a <CTRL-C> during a MERGE does not SIG-11
# gtm8530 [shaha]	Verify that a null $SHELL does not cause ZSYSTEM to operate badly
# gtm8522 [nars]	GT.M needs to correctly handle some pattern specifications with alternations
# gtm8177 [duzang]	Customer scenario involving instance freeze and SIGTERM causing hang
# gtm8535 [nars]	SIG-11 when 32K process limit is reached for the instance file if QDBRUNDOWN is not enabled
# gtm8539 [maimoneb]	Verify appropriate number of fsyncs from epoch taper
# gtm8538 [nars]	MUTEXFRCDTERM messages when 32K processes attach to a read-only replication instance file
# gtm4759 [shaha]	Restoring a prior $ZGBLDIR after a NEW should not result in an error
# gtm8549 [hathawayc]	Add test to check for partial label matches
# gtm8357 [jagadeesh]	An environment variable with an initial value for $ZSTEP
# gtm7922 [jagadeesh]	MUPIP EXTRACT should check gvcst_get return value to avoid uninitialized mval usage.
# gtm8558 [rog]		Verify that an empty 2nd argument does not leave a $FNUMBER() result vulnerable to trashing
#-------------------------------------------------------------------------------------

echo "v63000a test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8523 gtm8454 gtm8530 gtm8522 gtm8539 gtm4759 gtm8549 gtm8540 gtm8357 gtm7922 gtm8558"
setenv subtest_list_replic     "gtm8177 gtm8535 gtm8538"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
if ("HOST_LINUX_IX86" == "$gtm_test_os_machtype") then
        setenv subtest_exclude_list "$subtest_exclude_list gtm8549"	#32-bit does not resolve $TEXT() at compile time
endif

# filter out tests that cannot run in pro
if ("pro" == "$tst_image") then
	# gtm8535 and gtm8538 rely on gtm_db_counter_sem_incr = 8K (not supported in pro)
	setenv subtest_exclude_list "$subtest_exclude_list gtm8535 gtm8538 gtm7922"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63000a test DONE."
