#!/usr/local/bin/tcsh -f

# gtcm_omi_enc [s7kr] <Encryption test for gtcm server without gtm_passwd>
echo "GTCM test starts..."

if( $LFE == "L" ) then
	setenv subtest_list "basic"
else
	setenv subtest_list "basic resil"
	if ("ENCRYPT" == "$test_encryption") then
		setenv subtest_list "$subtest_list gtcm_omi_enc"
	endif
endif
$gtm_tst/com/submit_subtest.csh
echo "GTCM test DONE."
