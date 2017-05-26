#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
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
# gtm6892 		[karthikk] 	Test that fsync latch is released in case of error return from fsync in jnl_fsync.
# gtm7412 		[rog]		Test for warnings with a database with -extension=0.
# gtm7595 		[connellb] 	Test new non-TP journal buffer allocation scheme in gvcst_init.
# gtm7268 		[duzang]	Test journal flush/out-of-space with multiple processes.
# zalloc_overflow	[sopini]	Test that verifies that no overflows happen in $zrealstor, $zallocstor, and $zusedstor calculations.
# gtm7642               [estess]        Check that TRESTART both inside and outside an error handler generates TLVLZERO.
# gtm7093 		[zouc] 		Test zprint, zbreak, or $Text() nonexistent triggers.
# interrupt_x_time 	[sopini]	Test that ensures no hang in time-related functions, such as ctime(), localtime(), and so on.
# gtm6181		[base]		Validate LKE -lock parameter works with '_' operator, accepts $CHAR/ZCHAR prefixes ignoring
#					case, validates ')' at the end, rejects empty parans, allows using ',' in quotes.
# peekaboo		[estess]	Test $ZPEEK() invocations of various types. Note requires GTMDefinedTypes.m to be available.
# gtm6548a 		[bahirs] 	Verify JOB command process-parameters functionality.
# gtm6548b 		[bahirs] 	Verify JOB command issues NULLENTRYREF error if entryref is not specified for the command.
# gtm6548c 		[bahirs] 	Verify JOB command process-parameters functionality if JOB command is used through callins.
# gtm7503		[base]		Validate semaphores are properly released if an error occurs inside db_init().
# gtm7636 		[karthikk] 	Test that failures during file extensions in MM are handled gracefully.
# zgotozintr		[estess]	Verify ZGOTO with entryref to $ZINTERRUPT frame raises ZGOTOZINTRERR error.
# gtm7683		[connellb]	Test MUPIP SET configurable mutex queue space.
# fallintoflst		[sopini]	Test that FALLINTOFLST error is issued if we fall-through to a label with a formallist.
# gtm7718		[connellb]	Test HANG accuracy.
# gtm7666		[base]		Verify return status is non-zero if an error occurs during database shutdown or before.
# gtm7616		[shaha]		Test that bad IPCS values cannot cause MUPIP RUNDOWN to assert fail.
# rundown_override	[sopini]	Test to ensure that MUPIP RUNDOWN issues an error if attempted on a previously crashed
# 					replication- or journaling-enabled database unless an OVERRIDE qualifier is provided.
# gtmdist 		[bahirs] 	Test that JOB command uses the same mumps executable as that of parent to start the new mumps
# 					process.
#-------------------------------------------------------------------------------------

echo "v60002 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm6892 gtm7412 gtm7595 gtm7268 zalloc_overflow gtm7642 gtm7093 interrupt_x_time gtm6181"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm6548a gtm6548b gtm6548c gtm7503 zgotozintr gtm7683 fallintoflst"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7718 gtm7666 gtm7616"
#setenv subtest_list_non_replic "$subtest_list_non_replic gtmdist"
setenv subtest_list_replic     "gtm7636 peekaboo rundown_override"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
# gtm7666 TEMPORARILY DISABLED because it is causing hangs. Re-enable and update outref when issue is resolved.
# When re-enabling make sure to add gtm7666 to PRO subtest_exclude_list below.
setenv subtest_exclude_list 		"gtm7666"

# Filter out tests that cannot run on platforms that don't support triggers
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list	"$subtest_exclude_list gtm7093"
endif

# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list	"$subtest_exclude_list gtm6892 zalloc_overflow gtm7503"
endif

# gtm7636 is written for MM and uses white box test case. Disable for the other cases
if (("pro" == "$tst_image") || ("BG" == $acc_meth)) then
	setenv subtest_exclude_list	"$subtest_exclude_list gtm7636"
endif

# The rundown_override test is designed for BG
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list	"$subtest_exclude_list rundown_override"
endif

# Filter out tests that only run on Linux
if ("linux" != $gtm_test_osname) then
	setenv subtest_exclude_list	"$subtest_exclude_list gtm7268"
endif

# If IGS is not available, filter out tests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7268"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v60002 test DONE."
