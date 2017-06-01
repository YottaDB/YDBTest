#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
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
# gtm7762	[hathawayc]	Tests to verify that generated assembly has concatenated all string literals
# gtm8190	[base]		Verfiy that NONTPRESTART messages appear in the log when a non-tp transaction is restarted
# gtm6301	[partridger]	white box test for secshr_db_clnup handling of reads in progress
# gtm8394	[nars]		GTMASSERT in mur_insert_prev.c line 148 in case of GTM-E-MEMORY interrupted rollbacks
# gtm6220	[maimoneb]	Verify proper repositioning of assert
# gtm8340	[duzang]	Test that starting and stopping helpers works correctly
# gtm6114	[partridger]	Verify ZMESSAGE with indirection in its arguments produces the appropriate error and $ZSTATUS
# gtm8009	[maimoneb]	Verify open files descriptors don't get passed to exec'd children
# gtm8296	[base]		Verify PEEKBYNAME correctly invokes ZPEEK
# gtm8423	[shaha]		Ensure that the internal filters can handle transactions larger than 2MB
# gtm8417	[shaha]		Verify GTM-8417
# gtm8433	[partridger]	Verify ZSHOW "V":gvn does item continuation & that ^%ZSHOWVLCL can restore lvns from the result
# gtm8440	[partridger]	Validate OPEN, USE, CLOSE give appropriate errors for super long device names
# gtm6388	[shaha]		MUPIP EXTRACT and MUPIP JOURNAL -EXTRACT do fewer writes
# gtm8450	[partridger]	Validate that $ZGETJPI() returns large values correctly
# gtm7291	[nars]		Add test for GDINVALID error that it prints the .. syntax
# gtm8431	[partridger]	Validate $TEXT() of ^GTM$DMOD or ^GTM$CI returns an empty string not produces a RPARENMISSING
# gtm8455	[partridger]	Check that a process doing database initialization does not assert due to a MUPIP STOP (SIGTERM)
# gtm8464	[maimoneb]	Verify that MUPIP EXTRACT with encryption properly handles multiple regions mapped to the same file
# gtm8112	[shaha]		Verify changes from clang and coverity audits
# gtm8468	[kishore]	Verify that source server keeps its open jnl files minimal whether it starts with a non-zero or zero backlog
# gtm8137	[base]		Verify counter semaphore limit do not prevent more than 32K processes from starting
# gtm8481	[partridger/duzang]	Verify fix for fast integ sig-11
# gtm8471	[base]		Verify that gtmsecshr does not overwrite NULL to $gtm_autorelink_ctlmax
# gtm8486	[shaha]		Verify that changing ZROutines to a bogus value does not SIG-11
# gtm8034	[shaha]		Verify JOB command can use the same file for OUTPUT and ERROR with VIEW "JOBPID":1
# gtm8403	[shaha]		%MPIECE must new its locals
# gtm8483	[maimoneb]	Verify journal extract does not reset the crash flag
# gtm8404	[hathawayc]	Verifies the GTM-8404 cmpile optimization works and performs several edge tests
# gtm8495	[partridger]	Verify that DSE correctly interprets keys when switching between a bad block and a good one
# gtm8494	[kishore] 	Verify MUPIP BACKUP creates a consistent instance file backup relative to the db backup
# gtm8499	[nars]		KILL ^GBLNODE terminates abnormally with SIG-11 in rare situations
# gtm8501	[duzang]	Verify that errors during exit from mupip/dse/lke don't issue NOCHLEFT
# gtm8076	[duzang]	Try to recreate a customer scenario which resulted in a journal pool with write/write_addr out of sync
# gtm6928       [jagadeeshr]    shutdown source server if backlog is zero or timeout occurs. Whichever comes first.
# gtm8511	[shaha]		DSE should not error out on startup
#-------------------------------------------------------------------------------------

echo "v63000 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "gtm8511"
setenv subtest_list_non_replic "gtm7762 gtm8190 gtm6301 gtm8394 gtm6220 gtm6114 gtm8009 gtm8417 gtm8433 gtm8440"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm6388 gtm8450 gtm7291 gtm8431 gtm8455 gtm8464 gtm8112"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8137 gtm8481 gtm8471 gtm8486 gtm8034 gtm8403 gtm8483"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8404 gtm8495 gtm8499"
setenv subtest_list_replic     "gtm8340 gtm8296 gtm8423 gtm8468 gtm8494 gtm8501 gtm8076 gtm6928"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm6301 gtm8450 gtm8455 gtm8137"
endif

# gtm8394 requires "limit vmemoryuse" to work which does not currently on AIX and HPUX so disable this test there.
# Newer glibc implementations suffer from the below. Exclude hosts which have an affected libc6 version
# 	Erroneous "libgcc_s.so.1 must be installed for pthread_cancel to work" message
# 	https://sourceware.org/bugzilla/show_bug.cgi?id=13119
if (("hp-ux" == "$gtm_test_osname") || ("aix" == "$gtm_test_osname") || ($HOST:ar =~ {thunder,bolt,scylla,charybdis,bahirs} ) ) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8394"
endif

# some tests don't work on x86 (32-bit) platforms due to requiring that mumps support the -list and -machine options
if ("HOST_LINUX_IX86" == "$gtm_test_os_machtype") then
        setenv subtest_exclude_list "$subtest_exclude_list gtm7762 gtm8404"
endif

# gtm8417 relies on auto-relink, disable it on unsupported platform
if (("hp-ux" == "$gtm_test_osname") || ("HOST_LINUX_IX86" == "$gtm_test_os_machtype")) then
        setenv subtest_exclude_list "$subtest_exclude_list gtm8417"
endif

# Exclude tests which require encryption
if ("NON_ENCRYPT" == $test_encryption) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8464"
endif

# Exclude tests which only run on Linux
if ("linux" != "$gtm_test_osname") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8076"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8423"
endif

# If IGS is not available, filter out tests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8076"
endif

if ($?gtm_test_temporary_disable) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8190"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63000 test DONE."
