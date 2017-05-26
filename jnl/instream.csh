#!/usr/local/bin/tcsh -f
#
###################################
### instream.csh for jnl test ###
###################################
#
# Talked with Layek, and he suggested to remove subtest jnl_multi_reg since it iw covered by other tests - zhouc - 05/14/2003
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
setenv gtm_test_jnl "NON_SETJNL"
echo "JNL test starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
if ($LFE == "L" ) then
	if ($?test_replic == 1) then
		setenv subtest_list "jnl0 jnl2"
	else
		setenv subtest_list "light_jnl jnl_set"
	endif
endif
if ($LFE == "F") then
	if ($?test_replic == 1) then
		setenv subtest_list "jnl0 jnl2 tp redirectfwd"
	else
		setenv subtest_list "light_jnl jnl0 jnl2 jnl3 tp redirectfwd jnl_set recover jnl_logical"
	endif
endif
if ($LFE == "E") then
	if ($?test_replic == 1) then
		setenv subtest_list "jnl0 jnl2 tp redirectfwd multi_jnl_recover"
	else
		setenv subtest_list "jnl0 jnl2 jnl3 tp redirectfwd multi_jnl_recover dse_basic_jnl dse_map_jnl "
		if (($?gtm_test_tp) && ($gtm_test_tp != "NON_TP")) then
			setenv subtest_list "$subtest_list zt_multi"
		endif
		setenv subtest_list "$subtest_list jnl_set c9606-000088 recover jnl_logical"
		if ($HOSTOS != "AIX") then
			setenv unicode_testlist "redirect_unicode"
			if ( "TRUE" == $gtm_test_unicode_support ) setenv subtest_list "$subtest_list $unicode_testlist"
		endif
	endif
endif
# filter out subtests that cannot pass with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "light_jnl jnl0 jnl3 tp dse_basic_jnl dse_map_jnl zt_multi c9606-000088"
endif
$gtm_tst/com/submit_subtest.csh
echo "JNL test DONE."
#
##################################
###          END               ###
##################################
