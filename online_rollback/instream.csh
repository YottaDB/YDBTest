#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
# basic			[shaha]		basic online rollback test which does a lot more than the basics
# tightloopreader	[shaha]		adaptation of bashirs first failure generating test
# trestartrootverify	[shaha]		simple test case for pTarg failure
# kiptrestart		[shaha]		testing for Kill-In-Progress
# default		[shaha]		validate that rollback's default operation is noonline
# dbformat		[shaha]		validate that online rollback will not proceed on a V4 DB
# trigorlbk		[shaha]		use online rollback to roll back a trigger
# triginstallorlbk	[shaha]		ensure trigger installation operations work with online rollback
# forest		[shaha]		testing with multiple secondaries
# cascade		[shaha]		testing with pipe-lined replication
# orlbkb4regopen 	[karthikk] 	ensures regions opened after an online rollback issue DBROLLEDBACK error as appropriate
# gtm8421		[shaha]		Receivers started with -autorollback should not exit if online rollback did nothing

echo "online_rollback test starts..."
if ($?test_replic == 0) then
	echo "Online Rollback requires -replic"
	exit -1
endif

# randomize TP settings here so that we don't need two entries in the E_ALL
# NOTE: imtp will do NON_TP transactions even when run with TP, this may be a
# moot point to actually do this randomization
set choices = "TP TP NON_TP"					# weight TP heavier
if ($gtm_test_trigger == 0) set choices = "TP NON_TP NON_TP"	# weight NON_TP heavier when triggers are enabled
setenv gtm_test_tp `$gtm_exe/mumps -run chooseamong $choices`

# All tests need these ENV VARs
setenv gtm_test_jnl "SETJNL"
setenv gtm_test_mupip_set_version "disable"	# ONLINE ROLLBACK cannot work with V4 format databases
source $gtm_tst/com/gtm_test_setbeforeimage.csh	# ROLLBACK needs before image journaling for backward recovery
setenv gtm_test_autorollback "TRUE"		# Receiver server will terminate without -autorollback
setenv gtm_test_onlinerollback "TRUE"		# Tell imptp that it needs to handle online rollback

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "basic tightloopreader trestartrootverify kiptrestart"
setenv subtest_list_replic     "$subtest_list_replic default dbformat trigorlbk triginstallorlbk orlbkb4regopen"
setenv subtest_list_replic     "$subtest_list_replic gtm8421"

# the multilevel MSR test take at least 5 minutes which more than triples current online_rollback test time
if ("L" !=  $LFE) then
	setenv subtest_list_replic "$subtest_list_replic cascade forest"
endif

setenv subtest_list "$subtest_list_common $subtest_list_replic"

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# HPPA does not do triggers, so exclude subtests that require $ztrigger functionality
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
        setenv subtest_exclude_list     "$subtest_exclude_list trigorlbk triginstallorlbk"
endif

# The below subtest uses MUPIP SET -VERSION which is not supported in GT.M V7.0-000 (YottaDB r2.00). Therefore disable it for now.
setenv subtest_exclude_list "$subtest_exclude_list dbformat"	# [UPGRADE_DOWNGRADE_UNSUPPORTED]

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "online_rollback test DONE."

