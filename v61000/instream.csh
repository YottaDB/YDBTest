#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
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
# gtm7804			[base]		Verify free mutex slots are not consumed by the same process.
# gtm7836			[connellb]	Test sorts-after operator (]]) with NOUNDEF.
# intrpt_wcs_wtstart		[sopini]	Verifies that killing a writer process inside wcs_wtstart() does not cause database
#						damage, create out-of-design situations, or result in its own or other processes'
#						ungraceful termination.
# setitimer_fail		[sopini]	Verify that a syslog message and a fatal rts_error is generated when setitimer
# 						returns an error status.
# gtm7845			[base]		Verify that MUPIP RUNDOWN -FILE clears semaphores and shared memory.
#						Note: -override flag inside MUPIP RUNDOWN might be randomized once GTM-7859 is fixed.
# gtm7858			[base]		Verify GTMSECSHRVFID is not issued if the kill() target PID does not exist (ESRCH).
# gtm7868 			[bahirs] 	Verify that MUPIP LOAD issues FILEOPENFAIL error if input file is absent.
# gtm7750			[sopini]	Verify that recompiles of a source file only happen if it is newer than the object
#						file by at least one nanosecond (where platforms support that).
# gtm7864			[base]		Verify REPLINSTDBMATCH is not issued unnecessarily
# gtm7756 			[bahirs] 	Verify that native size related integrity checks are passed even when access method
#						is switched from MM to BG.
# gtm7756_1 			[bahirs] 	Verify that INTEG check passes after the truncation of database.
# gtm7896			[estess]	Test $ZPIECE with non-UTF8 separator char in UTF8 mode
# key2big			[kishoreh]	A global reference following a KEY2BIG error should not cause assert failure or core
# gtm7769			[nars,kishoreh]	MUPIP JOURNAL -EXTRACT -GLOBAL works incorrectly if string subscript has embedded double-quotes and * is used
# gtm7923			[nars]		Test that long patterns give PATMAXLEN error instead of SIG-11
# repl_crash_err1		[base]		Verify REPLINSTDBMATCH is not issued incorrectly
# repl_crash_err2		[base]		Verify REPLREQROLLBACK is issued properly
#-------------------------------------------------------------------------------------

echo "v61000 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm7804 gtm7836 intrpt_wcs_wtstart setitimer_fail gtm7845 gtm7868 gtm7750 gtm7756"
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7756_1 gtm7896 key2big gtm7769 gtm7923"
setenv subtest_list_replic     "gtm7858 gtm7864 repl_crash_err1 repl_crash_err2"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list	"$subtest_exclude_list intrpt_wcs_wtstart setitimer_fail gtm7858 repl_crash_err2"
else if ("linux" != $gtm_test_osname) then
	# Filter out white box tests that cannot run even in dbg on non-linux platforms (e.g. cygwin, MacOS)
	# The setitimer_fail subtest script has been reworked to reflect the POSIX timer changes (#205) which affect
	# only linux. So this subtest will fail on non-linux platforms which continue to use non-posix timers (setitimer()).
	setenv subtest_exclude_list	"$subtest_exclude_list setitimer_fail"
endif

# The below subtest should always run in UTF-8 mode. Disable if unicode is not supported
if ( "TRUE" != $gtm_test_unicode_support ) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7896"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v61000 test DONE."
