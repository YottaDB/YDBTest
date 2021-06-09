#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#########################################
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# badlocknest		[bdw]		 Test that raises a %YDB-E-BADLOCKNEST
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
#
#
echo "LOCKS test Starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv subtest_list_common "lke1 lke2 lkeexact locks_main locks_fail multi_user_lock"
setenv subtest_list_non_replic	"badlocknest"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list ""
if ((0 != $test_collation_no) || ($?test_replic)) then
	# no need to test multi user with collation or replication
	setenv subtest_exclude_list "multi_user_lock"
endif

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list multi_user_lock"
endif

$gtm_tst/com/submit_subtest.csh
echo "LOCKS test Done..."
#
##################################
