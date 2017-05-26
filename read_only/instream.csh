#!/usr/local/bin/tcsh -f
#
###################################
### instream.csh for read_only test ###
###################################
#
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
echo "READ_ONLY test Starts..."

# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

if (($LFE == "L")||($test_region == "SINGLE_REG")) then
	setenv subtest_list "singlereg"
else
	setenv subtest_list "singlereg multireg"
endif
# filter out subtests that cannot pass with MM
# multireg	MM database cannot be frozen
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "multireg"
endif
# Now start test
$gtm_tst/com/submit_subtest.csh
echo "READ_ONLY test DONE."
#
##################################
###          END               ###
##################################
