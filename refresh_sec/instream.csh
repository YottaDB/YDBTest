#!/usr/local/bin/tcsh -f
#
# refresh_secondary_from_secondary [Balaji]	Test refreshing the secondary from another secondary
echo "refresh_secondary tests starts"
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn 1
####################################################################################

setenv DBCERTIFY "$gtm_exe/dbcertify"
#setenv MUPIPV5 "$gtm_exe/mupip"

##
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "refresh_secondary use_backup_and_recover refresh_secondary_from_secondary"
setenv subtest_list_common ""
#
######################################################
if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
######################################################
# filter out subtests that cannot pass with MM
# refresh_secondary	Needs upgrade/downgrade
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "refresh_secondary"
endif
#
$gtm_tst/com/submit_subtest.csh
echo "refresh_secondary tests ends"
