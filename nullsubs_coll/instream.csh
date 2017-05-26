#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#####################################################
# C9D03-002251 Allow Existing /Prohibit New Null Subscripts
#####################################################
echo "Null Subscripts test starts ..."

# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

setenv subtest_list_common ""
#
setenv subtest_list_non_replic "call_zwr_go gde_com_nullsub merge_glob_loc multipledb_binload stdnullcoll checkfunc_alex jnl_extract mu_bin_xtract_load multipledb_binxtract lclvarquery"
setenv subtest_list_replic     ""

#####################################################
if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
#####################################################
# filter out subtests that cannot pass with encryption, needs a V4 version, or MM
# mu_bin_xtract_load	needs V4 database
if (("ENCRYPT" == "$test_encryption" ) || ($?gtm_platform_no_V4) || ("MM" == $acc_meth)) then
	setenv subtest_exclude_list "$subtest_exclude_list mu_bin_xtract_load"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list mu_bin_xtract_load"
endif
$gtm_tst/com/submit_subtest.csh
echo "Null Subscripts test done."
