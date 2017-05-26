#!/usr/local/bin/tcsh -f
#
#####################################################
# C9D03-002250 Support Long Names
# global/local/routine/label/region/segment names
#####################################################
# For each subtest written, let's fill out the author/subtest info:
# [author] subtest_name
#####################################################

echo "Long Names test starts ..."

setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

setenv subtest_list_common ""
#
setenv subtest_list_non_replic "gld_compatibility"
setenv subtest_list_replic     ""

#####################################################
if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
#####################################################

$gtm_tst/com/submit_subtest.csh
echo "Long Names test DONE."
