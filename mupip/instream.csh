#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
###################################
### instream.csh for mupip test ###
###################################
#
# mu_stop is made obsolete, because dual_fail_extend has better mupip stop test: Layek 03/26/01
# mu_reorg is also not needed. reorg test is more extensive: Layek 03/26/01
#
# mu_backup_tn_reset [s7mj] subtest for test testing mupip incremental backup after tn_reset.
# mu_load_err [e3009839] subtest for testing mupip load error conditions (for now binary format)

# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
echo "MUPIP test Starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "mu_backup mu_create mu_extend mu_freeze mu_integ mu_load mu_load_no_leak mu_set"
setenv subtest_list_non_replic "mu_rundown mu_backup_tn_reset mu_load_err D9J02002719 D9J02002719_1"
setenv subtest_list_replic     "mu_rollback1 mu_rundown_no_ipcrm1"

if ( $LFE == "E" ) then
	setenv subtest_list_common "$subtest_list_common mu_load2 mu_extract"
endif

if ( "TRUE" == $gtm_test_unicode_support ) then
	setenv subtest_list_non_replic "$subtest_list_non_replic mu_unicode_backup mu_unicode_extract_load mu_unicode_integ"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list 		""
if (($?test_replic == 0) && ("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	# Do not run mu_extend test in replication mode on platforms that cannot dynamically extend files in MM mode
	# because they cannot get standalone access to extend
	setenv subtest_exclude_list "mu_extend"
endif

if ("HOST_OS390_S390" == "$gtm_test_os_machtype") then
	# For HOST_OS390_S390 : Until we can make bpxtrace work, skip this test.
	setenv subtest_exclude_list "$subtest_exclude_list D9J02002719_1"
endif

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list mu_load_no_leak"
endif

# mu_set has checks related to Defer Allocation, which is not supported Solaris and HPUX
# It is not worth the time trying to exclude Defer Allocation related checks in musetchk.m - Disable the entire subtest instead
if ($HOSTOS =~ {SunOS,HP-UX}) then
	setenv subtest_exclude_list "$subtest_exclude_list mu_set"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "MUPIP test DONE."
#
##################################
###          END               ###
##################################
