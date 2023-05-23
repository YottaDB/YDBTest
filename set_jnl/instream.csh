#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
###################################
### instream.csh for mupip set jnl test ###
###################################
#
# List of all subtests:
# jnlmsg basic jnl_filename jnl_state_switch mupip_backup replic_qualifier
# qualifiers_with_arg
# jnl_stand_alone
# repl_stand_alone (replic only)
# mu_backup_sa_access mupip_backup_0_1 C9C01_001899_repeat_switch
# C9C01_001899_repeat_switch subtest is removed from set_jnl test
# and merged into recov test - mohammad 04/28/2003
setenv gtm_test_jnl "NON_SETJNL"
echo "MUPIP SET JNL test starts..."

# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
if (0 != $?test_replic) then
	if ( $LFE != "E" ) then
		echo "No applicable subtest"
		exit
	endif
	setenv subtest_list "repl_stand_alone"
	setenv subtest_list "$subtest_list autoswitch1 autoswitch2 autoswitchbigtp autoswitchtp autoswitchrules"
	if ($HOSTOS != "AIX") then
		if ( "TRUE" == $gtm_test_unicode_support ) then
			setenv subtest_list "$subtest_list unicode_dir_autoswitch_replic"
		endif
	endif
else
	# NON REPLIC
	# For "L" following list will run
	setenv subtest_list "mupip_backup c9903-000899 jnlmsg basic jnl_filename jnl_state_switch replic_qualifier"
	if ( $LFE == "F" ) then
		setenv subtest_list "$subtest_list qualifiers_with_arg"
	endif
	if ( $LFE == "E" ) then
		setenv subtest_list "$subtest_list qualifiers_with_arg mu_backup_sa_access"
		setenv subtest_list "$subtest_list jnl_stand_alone autoswitch1"
		setenv subtest_list "$subtest_list autoswitch2 autoswitchbigtp autoswitchtp autoswitchrules autoswitch_chng_auto"
		if ($HOSTOS != "AIX") then
			if ( "TRUE" == $gtm_test_unicode_support ) then
				setenv subtest_list "$subtest_list unicode_mupip_backup"
			endif
		endif
	endif
endif
# filter out subtests that cannot pass with MM
# jnlmsg		Tests both BEFORE and NOBEFORE journal imaging
# basic			Tests both BEFORE and NOBEFORE journal imaging
# jnl_filename		Switches between BEFORE and NOBEFORE journal imaging
# jnl_state_switch	Tests both BEFORE and NOBEFORE journal imaging
# replic_qualifier	Tests both BEFORE and NOBEFORE journal imaging
# repl_stand_alone	BEFORE image journaling required
# jnl_stand_alone	Tests both BEFORE and NOBEFORE journal imaging
# autoswitch1		BEFORE image journaling/backward recovery
# autoswitch2		BEFORE image journaling/backward recovery
# autoswitchbigtp	BEFORE image journaling/backward recovery
# autoswitchtp		BEFORE image journaling/backward recovery
# autoswitch_chng_auto
setenv subtest_exclude_list ""
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "jnlmsg basic jnl_filename jnl_state_switch replic_qualifier repl_stand_alone"
	setenv subtest_exclude_list "$subtest_exclude_list jnl_stand_alone autoswitch1 autoswitch2 autoswitchbigtp"
	setenv subtest_exclude_list "$subtest_exclude_list autoswitchtp autoswitch_chng_auto"
endif

if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	# Disable below subtest until T63002 is available as it fails occasionally with JNLFILEOPNERR/ENO2 errors.
	setenv subtest_exclude_list "$subtest_exclude_list unicode_dir_autoswitch_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "MUPIP SET JNL test DONE."
#
##################################
###          END               ###
##################################
