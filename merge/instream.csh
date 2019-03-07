#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
if ("ENCRYPT" == "$test_encryption") then
	# This test has had RF_sync issues which showed the servers stuck in BF_encrypt() for a long time
	# Disabling BLOWFISHCFB since it seems to be a known issue with BLOWFISHCFB - Check <rf_sync_timeout_BF_encrypt>
	# It is easier to re-randomize than to check if gtm_crypt_plugin is set and if so check if it points to BLOWFISHCFB
	unsetenv gtm_crypt_plugin
	setenv gtm_test_exclude_encralgo BLOWFISHCFB
	echo "# Encryption algorithm re-randomized by the test"	>>&! settings.csh
	source $gtm_tst/com/set_encryption_lib_and_algo.csh	>>&! settings.csh
endif
echo "MERGE COMMAND IMPLEMENTATION test Starts..."
setenv subtest_list "MVTS_MERGE gbl2gbl gbl2lcl lcl2gbl indirection"
if ( $LFE == "F" ) then
	setenv subtest_list "$subtest_list errors"
endif
if ( $LFE == "E" ) then
	setenv subtest_list "$subtest_list errors extgbl1 extgbl2"
	if ( "TRUE" == $gtm_test_unicode_support ) setenv subtest_list "$subtest_list ugbl2gbl ugbl2lcl ulcl2gbl ulcl2lcl"
	if ( "GT.CM" != $test_gtm_gtcm) then
		setenv subtest_list "$subtest_list tp_stress misclv"
	endif
endif
if ( "GT.CM" != $test_gtm_gtcm) then
	setenv subtest_list "$subtest_list gblcol lcl2lcl falsedsc nullsubs mrgclnup"
	if ("L" !=  $LFE) then
		setenv subtest_list "$subtest_list tp_simple lclcol"
	endif
endif
setenv subtest_exclude_list ""

# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list tp_stress"
endif

$gtm_tst/com/submit_subtest.csh
echo "MERGE COMMAND IMPLEMENTATION test Ends..."
