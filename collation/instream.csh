#!/usr/local/bin/tcsh -f

# this tests handles collation itself, so should not be called with collation
echo "COLLATION test Starts..."

setenv subtest_list "def_to_pol pol_to_def"
setenv unicode_testlist ""

if ( $LFE == "E" ) then  
	setenv subtest_list "$subtest_list pol_to_pol pol_to_revpol local_col col_nct ylct"
	if (("TRUE" == $gtm_test_unicode_support ) && ($gtm_test_osname != "osf1")) then
		setenv unicode_testlist "def_to_chn local_chn col_nct_with_chn test_opers"
	endif
endif

setenv subtest_list "$subtest_list $unicode_testlist "
$gtm_tst/com/submit_subtest.csh
echo "COLLATION test Ends..."
