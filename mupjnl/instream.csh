#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
# For all the journal tests that don't need rollbacks.
#####################################################
# [Chunling] C9A06001511
# [Chunling] C9B09001732 - merged to bij_withdata
# [Chunling] C9C05001996
# [Chunling] C9C06002009
# [Chunling] C9C06002010 - merged to bij_withdata
# [Chunling] C9C06002017
# [Chunling] C9C06002018
# [Chunling] C9C06002025 - duplicate with jnl_crash test
# [Chunling] C9C12002203
# [Chunling] D9C06002153
# [Chunling] D9C12002269
# [Chunling] jnl_name
# [Chunling] jnl_view
# [Chunling] ztp_broken_mul_region
# [Nergis] test_extract_show_single
# [Nergis] test_extract_show_multi
# [Nergis] test_extract_show_select
# [Nergis] time_qualifier_since_before_after
# [Nergis] test_verbose
# [Nergis] C9B11001825
# [Nergis] C9C05002004
# [Nergis] mu_jnl_extract_collated_globals
# [Nergis] multi_generation_ztp
# [Nergis] max_tp_ztp_nesting
# [Mohammad] nbij_nodata
# [Mohammad] nbij_withdata
# [Mohammad] bij_nodata
# [Mohammad] bij_withdata
# [Mohammad] mupjnl_withoutdb
# [Mohammad] recov_dbjnlmismatch
# [Mohammad] tp_ztp_mix
# [Mohammad] ztp_tp_multi_reg
# [Mohammad] ztp_broken_sing_reg
# [Mohammad] ztp_nested
# [Mohammad] ztp_nested_1
# [Mohammad] tp_nested
# [Mohammad] tp_nested_1
# [Mohammad] recov_post_jnl_switch
# [Mohammad] redirect_qualifier
# [Mohammad] C9B11001780
# [Mohammad] C9C07002078
# [Mohammad] recov_multi_jnl (prev name: jnl_file_name_forw_recov)
# [Mohammad] recov_standalone
# [Mohammad] new_jnl_back_recov
# [Mohammad] jnlcycle
# [Mohammad] ztp_tp_ntp_multi_process
# [Mohammad] src_svr_repl_config (prev name: replic_config)
# [Sade] tprbk_mem_corrupt
# recov_no_partial_replay [groverh] <Ensure recovery never plays half of a TP transaction into the db and the remaining half into a losttn file>
# in_order_recover [groverh] <Test that broken transactions are resolved in correct order>
# apply_trans_after_brkntrans [groverh] <Test that complete transactions even if they happen in time AFTER the earliest broken transaction are not considered lost and are played forward without issues>
# brkntrans_order [groverh] <Test that broken transactions which are ordered based on a missing region records get placed in an arbitrary order in the brokentn file>
# in_order_recover_nofence [groverh] <in_order_recover with no_fences>
# good_trans_aftr_brkn [groverh] <Test that a good transaction is not considered LOST even if happens AFTER a broken transaction in some other region>
# lost_multireg_recov [groverh] <Test that a good transaction is considered LOST if any of the regions included in the trans has see a BROKEN trans earlier>
# D9E02002419 [parentel] Test a recovery from an interrupted database file extension.
# D9D12002400 [parentel] Test for interrupted jnl file creation.
# C9C04001977 [parentel/duzang] Test for cre_jnl_file failures.
# ##disabled## C9A06001526 [parentel] Test for jnl_ensure_open failures.
# ##disabled## C9A06001526_replic [parentel] Test for jnl_ensure_open failures, replic.
# ##disabled## C9A06001526_gtcm [parentel] Test for jnl_ensure_open failures, GT.CM.
# gtm5007		[Kishore]   Test case to verify -parallel in mupip command overrides $gtm_mupjnl_parallel
# autoswitch_in_mupjnl	[Narayanan] Test case that induces a journal autoswitch while inside MUPIP JOURNAL RECOVER

echo "mupip journal test starts ..."

setenv gtm_test_spanreg 0	# TODO: temporarily disabled until Kishore gets to enabling this

# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

setenv subtest_list_common ""
setenv unicode_testlist "unicode_jnl_name"
#
setenv subtest_list_non_replic "jnl_name jnl_view ztp_broken_mul_region nbij_nodata nbij_withdata tp_ztp_mix"
setenv subtest_list_non_replic "$subtest_list_non_replic tprbk_mem_corrupt mu_jnl_disallow mu_jnl_extract_collated_globals"
setenv subtest_list_non_replic "$subtest_list_non_replic bij_nodata bij_withdata mupjnl_withoutdb recov_dbjnlmismatch"
setenv subtest_list_non_replic "$subtest_list_non_replic recov_multi_jnl new_jnl_back_recov recov_no_partial_replay"
setenv subtest_list_non_replic "$subtest_list_non_replic in_order_recover apply_trans_after_brkntrans brkntrans_order"
setenv subtest_list_non_replic "$subtest_list_non_replic in_order_recover_nofence good_trans_aftr_brkn lost_multireg_recov"
#
setenv subtest_list_replic "src_svr_repl_config"

if ("E" == $LFE) then
	setenv subtest_list_non_replic "$subtest_list_non_replic C9A06001511 redirect_qualifier C9C05001996 C9C06002009 C9C06002017"
	setenv subtest_list_non_replic "$subtest_list_non_replic C9C06002018 C9C12002203 D9C06002153 D9C12002269 C9B11001825"
	setenv subtest_list_non_replic "$subtest_list_non_replic C9C05002004 C9B11001780 C9C07002078 D9E02002419 D9D12002400 C9C04001977"
	setenv subtest_list_non_replic "$subtest_list_non_replic test_extract_show_single test_extract_show_multi test_extract_show_select multi_generation_ztp"
	setenv subtest_list_non_replic "$subtest_list_non_replic time_qualifier_since_before_after test_verbose"
	setenv subtest_list_non_replic "$subtest_list_non_replic max_tp_ztp_nesting tp_nested tp_nested_1 ztp_nested ztp_nested_1"
	setenv subtest_list_non_replic "$subtest_list_non_replic ztp_tp_multi_reg ztp_broken_sing_reg recov_post_jnl_switch"
	setenv subtest_list_non_replic "$subtest_list_non_replic recov_standalone jnlcycle ztp_tp_ntp_multi_process"
	setenv subtest_list_non_replic "$subtest_list_non_replic autoswitch_in_mupjnl gtm5007"
	if ($HOSTOS != "AIX") then
		if ( "TRUE" == $gtm_test_unicode_support ) setenv subtest_list_non_replic "$subtest_list_non_replic $unicode_testlist"
	endif
endif
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
# filter out subtests that cannot pass with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list src_svr_repl_config mu_jnl_extract_collated_globals"
	setenv subtest_exclude_list "$subtest_exclude_list bij_nodata bij_withdata mupjnl_withoutdb recov_dbjnlmismatch"
	setenv subtest_exclude_list "$subtest_exclude_list recov_multi_jnl new_jnl_back_recov C9C05001996 C9C06002009"
	setenv subtest_exclude_list "$subtest_exclude_list C9C06002017 D9E02002419 C9C06002018 C9C12002203 D9C06002153"
	setenv subtest_exclude_list "$subtest_exclude_list D9C12002269 C9B11001825 C9C05002004 C9B11001780 C9C07002078"
	setenv subtest_exclude_list "$subtest_exclude_list test_extract_show_single test_extract_show_multi D9D12002400"
	setenv subtest_exclude_list "$subtest_exclude_list test_extract_show_select time_qualifier_since_before_after"
	setenv subtest_exclude_list "$subtest_exclude_list test_verbose multi_generation_ztp max_tp_ztp_nesting tp_nested"
	setenv subtest_exclude_list "$subtest_exclude_list tp_nested_1 tp_nested_2 ztp_nested ztp_nested_1 ztp_tp_multi_reg"
	setenv subtest_exclude_list "$subtest_exclude_list ztp_broken_sing_reg recov_post_jnl_switch recov_standalone jnlcycle"
	setenv subtest_exclude_list "$subtest_exclude_list ztp_tp_ntp_multi_process C9C04001977 autoswitch_in_mupjnl"
endif

# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list C9C04001977 D9E02002419 D9D12002400"
endif

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list test_extract_show_single test_extract_show_multi test_extract_show_select multi_generation_ztp"
endif

if ("ENCRYPT" == "$test_encryption" ) then
	# The below subtest spawns off a lot of processes and those take a lot of time to finish due to encryption
	# initialization when opening each database region (there are 9 of those in this test). Therefore disable
	# this subtest if encryption is enabled.
	setenv subtest_exclude_list "$subtest_exclude_list ztp_tp_ntp_multi_process"
endif

$gtm_tst/com/submit_subtest.csh
#
echo "mupip journal test DONE."
