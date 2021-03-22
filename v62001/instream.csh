#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2021 YottaDB LLC and/or its subsidiaries.	#
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
# gtm8146		[rp]		Verify better $zsearch() stream behavior.
# gtm7321		[rp]		Verify test that the -nowarning compiler qualifier appropriately suppresses error messages.
# gtm8174		[rp]		Verify that 0**<negative number> gives DIVZERO.
# fast_timer		[sopini]	Verify accuracy of sleep durations produced by HANG.
# gtm8094updproc	[maimoneb]	Test to ensure failure to start update process behaves correctly.
# gtm8094hlpproc	[maimoneb]	Test to ensure failure to start helper processes behaves correctly.
# gtm8094fltproc	[maimoneb]	Test to ensure failure to start the filter process behaves correctly.
# gtm8094zedproc	[maimoneb]	Test to ensure failure to start the editor process behaves correctly.
# gtm8094secproc	[maimoneb]	Test to ensure failure to start the gtmsecshr process behaves correctly.
# gtm8094pipproc	[maimoneb]	Test to ensure failure to startup the piped process behaves correctly.
# gtm8106		[rp]		Verify VIEW "GVSRESET" and DSE CHANGE -FILEHEADER -GVSTATSRESET work; also VIEW accepts lower-case
#					region names and * as all regions.
# gtm7862		[duzang]	Verify that JNLFILEONLY removes the need to rollback on an SI secondary after a primary crash.
# gtm7779		[rp]		test crit stats in gvstats and $view("probecrit",<region>).
# gtm7843		[rp]		test to verify that an instance freeze seldom produces MUTEXLCKALERT messages.
# hash			[duzang]	Test hash functions.
# gtm8068 		[estess]	Test that mumps -run rtn does not assertpro() fail when rtn has a routine name other than 'rtn'.
# gtm8191		[rp]		Test to verify VIEW "POOLLIMIT and $VIEW("POOLLIMIT").
# gtm8206		[rp]		Test for <CTRL-C> during a local merge.
# gtm4414		[base]		Verify that specifying passcurlvn lets the parent process to pass its locals to the child
#

echo "v62001 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8146 gtm7321 gtm8174 fast_timer gtm8094updproc gtm8094hlpproc gtm8094fltproc"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8094zedproc gtm8094secproc gtm8094pipproc gtm8106 gtm7779 hash gtm8068"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8191 gtm8206 gtm4414"
setenv subtest_list_replic     "gtm7862 gtm7843"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out white-box tests that cannot run in pro.
if ("pro" == "$tst_image") then
        setenv subtest_exclude_list "$subtest_exclude_list gtm8094updproc gtm8094hlpproc gtm8094zedproc gtm8094secproc"
        setenv subtest_exclude_list "$subtest_exclude_list gtm8094pipproc"
else if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8094secproc"
endif

# Filter out certain subtests for some servers.
set hostn = $HOST:r:r:r

# Do not run fast_timer on inti as it is at times ridiculously slow.
if ("inti" == "$hostn") then
	setenv subtest_exclude_list "$subtest_exclude_list fast_timer"
endif

# Do not run gtm4414 on HP-UX because truss/strace output is not compatible
if ("HP-UX" == $HOSTOS) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm4414"
endif

if ("armv6l" == `uname -m`) then
	# The gtm7843 subtest has been seen to occasionally fail only on ARMV6L with a diff like the following.
	#	> Not expecting 2 MUTEXLCKALERTs
	# This is suspected to be a test timing issue due to a slow system.
	# Since all the MUTEXLCKALERT related code is portable and we have never seen a failure of this kind in
	# other architectures, disable this subtest on ARMV6L for now.
	setenv subtest_exclude_list "$subtest_exclude_list gtm7843"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v62001 test DONE."
