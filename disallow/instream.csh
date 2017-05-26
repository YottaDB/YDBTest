#!/usr/local/bin/tcsh -f
#
# D9D09002364 [Narayanan] Test for MUPIP and DSE disallows (dse_disallow, mupip_disallow subtests)
#
echo "disallow test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic ""
setenv subtest_list_non_replic "dse_disallow mupip_disallow"
#
if ($?test_replic == 1) then
        setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
        setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "disallow test DONE."
