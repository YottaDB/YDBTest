#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013, 2015 Fidelity National Information	#
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
# mupip_update_db_header	[sopini]	Verifies that journaling-related fields in the database file header are not updated on
# 						MUPIP SET -JOURNAL faiulure.
# intrpt_timer_handler		[sopini]	Verifies that no hang occurs when calling hiber_start() on an already interrupted
#						timer handler.
# wcs_flu_fail			[sopini]	Simulates an error inside wcs_flu(), and ensures that mu_rndwn_file.c responds
# 						accordingly, depending on standalone mode, and whether the OVERRIDE qualifer is present.
# gtm7623			[connellb]	Simulates pread() error in dsk_read(); expects DBFILERR as a result.
# C9709000247			[shaha]		MUPIP, DSE and LKE have on line help
# gtm7760			[connellb]	Verify triggered SETs protect value from stringpool garbage collection.
# gtm7761			[connellb]	Verify long expressions do not run out of temps.
# gtm7774			[connellb]	On Solaris, verify long concatenates give MAXARGCNT error instead of SIG-11.
# gtm7770			[shaha]		Verify that JOB parameters between 128 and 255 characters do not cause a SIG-11
# gtm7614			[base]		Verify that mutex deadlock check properly detects a deadlock and releases crits
#						owned by the waiter process
# gtm7528			[base]		Verify LKE and DSE restart db_init() if shared memory is removed after a semaphore bypass
# gtm7627 			[karthikk] 	Verify that older generation journal files are renamed with the current system time
#						rather than the time of last update.
# gtm7811			[estess]	Whitebox test case to verify MUPIP STOP during TP restart of a trigger doesn't
# 						assert fail. This test is dbg build only due to the whitebox.
# gtm5576 			[bahirs] 	Verify that wrong value of gtm_collate_1 does not result in SIG-11.
# gtm7777			[connellb]	Test VIEW keywords DBFLUSH, DBFSYNC, and EPOCH.
#-------------------------------------------------------------------------------------

echo "v60003 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "mupip_update_db_header intrpt_timer_handler wcs_flu_fail gtm7623 C9709000247 gtm7760 gtm7761"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7774 gtm7770 gtm7614 gtm7528 gtm7811 gtm7627 gtm5576 gtm7777"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list	"$subtest_exclude_list wcs_flu_fail gtm7623 gtm7614 gtm7528 gtm7811"
endif

# Filter out white box tests that cannot run with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list	"$subtest_exclude_list gtm7623"
endif

# Filter out tests that can only run on trigger-supported platforms
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
        setenv subtest_exclude_list     "$subtest_exclude_list gtm7760"
endif

# Run gtm7774 on Solaris and gtm7761 elsewhere
if ("HOST_SUNOS_SPARC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list     "$subtest_exclude_list gtm7761"
else
	setenv subtest_exclude_list     "$subtest_exclude_list gtm7774"
endif

# Filter out lester as that platform (hppa) cannot run triggers
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7811"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list mupip_update_db_header"
endif
if ($?gtm_test_temporary_disable) then
       setenv subtest_exclude_list "$subtest_exclude_list intrpt_timer_handler"
endif
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v60003 test DONE."
