#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
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
# gtm7395	[fayazia]	Opening directories should always return GTMEISDIR
# gtm7475 	[rog]		test of $zwrite() function
# gtm7461	[duzang]	Test freeze-on-error during rollback
# gtm7415	[fayazia]	$zmessage() can cause seg faults for some values
# gtm7281	[fayazia]	Tests return value for mumps on compile errors
# gtm7254	[base]		Verify M locks are reasonably fair
# gtm7497	[connellb]	Test indirection array removal
# gtm7497_trig	[connellb]	Test indirection array removal (trigger specific)
# gtm4115	[base]		Verify that MUPIP extract is able to redirect to standard output
# gtm3357	[fayazia]	ZMESSAGE should disallow certain errors conditions
# mumpsinbg 	[bahirs] 	Verify that mumps program runs correctly in the background.
# concbkup 	[bahirs] 	Verify that concurrent backup can-not be started
# gtm6395	[connellb]	Test indirect SET order of evaluation
# gtm7492	[connellb]	Test FOR fixes
# gtm7510	[base]		Check if LKS value in zshow "G" is right
# tprestart 	[bahirs] 	Verify that tprestart logging mechanism is properly controlled
#				by VIEW "LOGTPRESTART":<intval> and by gtm_tprestart_log_first and
#				gtm_tprestart_log_delta environment variables.
# verifyview	[bahirs]	verify VIEW "NOLOGTPRESTART" and $view("LOGTPRESTART") functionality.
# gtm_posix	[cronem]	Test the posix plugin installed in $gtm_com/gtmposix
# gtm7443	[nars]		Test that idle EPOCHs (JRI gvstat) are not written unnecessarily
# gtm7292	[fayazia]	MUPIP SIZE interface
# gtm3907	[rog]		Order of evaluation tests for side effects
# gtm7168 	[zouc] 		test keep_alive setting output in the replication log file
# gtm7478 	[bahirs] 	Verify the usage of gtm_extract_nocol environment variable. Verify that JOURNAL EXTRACT does
#				not get hung when INSTANCE is frozen.
# misceval	[connellb]	Various evaluation testcases for GTM-3907, GTM-6395, and GTM-5896
# gtm7541	[connellb]	Test some $order fixes
# gtm7538	[duzang]	Test that checkhealth works on a frozen instance in a particular set of circumstances
# gtm6015	[zouc]		test cmdline for jobbed process
# gtm7355	[estess]	Test nested error handling in multiple ways
# gtm7530	[duzang]	Verify that a catchup from a receiver can't freeze the source due to missing journal files
# gtm7458 	[karthikk] 	Test to ensure SIG-15 of receiver server (after a kill -9 of update process) followed by a
#				restart of receiver server doesn't cause REPLREQROLLBACK errors
# gtm7553	[base]		Test LKE SHOW -MEM displays LOCKSPACEINFO message
# gtm7501 	[rog]		Test exponentiation - apparently no prior test outside mvts and mugj
# gtm7525	[base]		Verify locks resume blocking wait after receiving an INTRPT
# gtm7495	[nars]    	Test that triggers dont misfire
# gtm7454	[zouc]		Test new mupip integ -fast scheme
# gtm7552	[nars]		Test that TPFAIL with LLLJ or LLLe does not happen anymore
#-------------------------------------------------------------------------------------

echo "v60001 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm7395 gtm7475 gtm7461 gtm7415 gtm7281 gtm7254 gtm7497 gtm7497_trig gtm4115 gtm3357 mumpsinbg"
setenv subtest_list_non_replic "${subtest_list_non_replic} concbkup gtm6395 gtm7492 gtm7510 tprestart verifyview gtm_posix"
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7443 gtm7292 gtm3907 gtm7478 misceval gtm7541 gtm6015 gtm7355 gtm7553"
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7501 gtm7525 gtm7495 gtm7454 gtm7552"
setenv subtest_list_replic     "gtm7168 gtm7538 gtm7530 gtm7458"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# Filter out tests that cannot run on platforms that don't support triggers
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7497_trig gtm7355 gtm7495"
endif
# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list concbkup gtm7454"
endif
if ($?gtm_test_temporary_disable) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm_posix"
endif
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v60001 test DONE."
