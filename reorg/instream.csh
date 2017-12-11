#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# restrict_region	[connellb]	Tests -REGION qualifer.
# truncate		[connellb]	Tests basic -TRUNCATE functionality.
# truncate_crash	[connellb]	Tests interrupted -TRUNCATE recovery.
# truncate_hasht	[connellb]	Verify REORG moves ^#t globals out of the way.
# gtm7519		[connellb]	Test for GVxxxFAIL 'XXXX' errors caused by truncate.
# gtm7688		[connellb]	Test for SIG-11s on small MM databases.
# gtm7430		[connellb]	Test for GTMASSERTs with -SELECT and long global names
#########################################
### instream.csh for mupip reorg test ###
#########################################
#
if ("$test_reorg" == "NON_REORG") then
	echo "This test is not applicable to NON_REORG"
	exit 1
endif
#Some of the tests do not use online-reorg, so set test_reorg to NON_REORG

#Calculate the number of global buffers being used, based on gtm_poollimit setting.
if ($?gtm_poollimit) then
	set pllimit=${gtm_poollimit:s/%//}
	if ($pllimit != $gtm_poollimit) then	# gtm_poollimit was in %. calculate the value.
		@ pllimit = $pllimit * 1024 / 100
	endif
else
	set pllimit=64
endif
# POOLLIMIT for MM will be 0
if ("MM" == $acc_meth) then
	set pllimit=0
endif
setenv gtm_poollimit_value $pllimit

echo "REORG test Starts..."
if ( $LFE == "L" ) then
	setenv subtest_list "coalsce star_rec reorg_stat hightree restrict_region truncate_simple truncate truncate_crash truncate_hasht"
else
	if (0 == $?test_replic) then
		setenv subtest_list "coalsce star_rec reorg_stat hightree restrict_region collation truncate_simple truncate truncate_crash"
		setenv subtest_list "$subtest_list truncate_hasht on_tp_jnl_multi_reorg on_ntp_njnl_reorg gtm7519 gtm7688 gtm7430"
	else
		setenv subtest_list "on_tp_jnl_multi_reorg on_ntp_njnl_reorg"
	endif
endif

set hostn = $HOST:ar
# If it is a replic run on charybdis with eotf enabled, limit align size to 16MB
if ( ("charybdis" == "$hostn") && ($gtm_test_do_eotf) && ($?test_replic) && (! $?gtm_test_replay) ) then
	# Each reorg encrypt causes 2 switches of journal files. Since it is done continuously in a loop,
	# it results in a lot of journal files for the source server to read. Until GTM-4928 is fixed, limit alignsize to 32768 (16MB)
	# 16MB because, at least one test failed with 32MB align size. (Few with 128MB and almost all failures analyzed were with 256MB)

	# For now, we've seen this test fail with this issue only on charybdis. Expand it to all servers if we see it fail elsewhere too
	if (32768 < $test_align) then
		setenv test_align 32768
		set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
		setenv tst_jnl_str $tstjnlstr
		echo '# tst_jnl_str modified by subtest'	>> settings.csh
		echo "setenv tst_jnl_str $tstjnlstr"		>> settings.csh
	endif
endif
# filter out subtests that cannot pass with MM
# on_tp_jnl_multi_reorg	Does backward recovery
setenv subtest_exclude_list ""
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list truncate_simple truncate truncate_crash truncate_hasht on_tp_jnl_multi_reorg gtm7519"
endif
# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list truncate_crash"
endif
# filter out tests that cannot run on platforms that don't support triggers
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
        setenv subtest_exclude_list "$subtest_exclude_list truncate_hasht"
endif
# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list on_ntp_njnl_reorg"
endif

$gtm_tst/com/submit_subtest.csh
echo "REORG test DONE."
#
##################################
###          END               ###
##################################
