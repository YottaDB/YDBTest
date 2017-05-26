#!/usr/local/bin/tcsh -f
#
echo "v42000 test Starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv subtest_list "jnl_link backup_jnl_link d001624 ztdttst zcmdltst c001583 startup_check fnquery d001725" 
setenv subtest_list "$subtest_list zshow zwrite gbldirerr trans2big jnl_link2"
$gtm_tst/com/submit_subtest.csh
echo "v42000 test DONE."
#
