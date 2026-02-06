#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic call_zwr_go"
setenv subtest_list_non_replic "$subtest_list_non_replic gde_com_nullsub"
setenv subtest_list_non_replic "$subtest_list_non_replic merge_glob_loc"
setenv subtest_list_non_replic "$subtest_list_non_replic multipledb_binload"
setenv subtest_list_non_replic "$subtest_list_non_replic stdnullcoll"
setenv subtest_list_non_replic "$subtest_list_non_replic checkfunc_alex"
setenv subtest_list_non_replic "$subtest_list_non_replic jnl_extract"
setenv subtest_list_non_replic "$subtest_list_non_replic multipledb_binxtract"
setenv subtest_list_non_replic "$subtest_list_non_replic lclvarquery"
setenv subtest_list_replic     ""

#####################################################
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
#####################################################

$gtm_tst/com/submit_subtest.csh
echo "Null Subscripts test done."
