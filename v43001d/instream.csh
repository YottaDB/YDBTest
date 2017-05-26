# ------------------------------------------------------------------------------
# for stuff fixed in V43001C/V43001D
# ------------------------------------------------------------------------------
# D9B12001998 [Narayanan] - Miscellaneous fixes to MUPIP INTEG -SUBSCRIPT qualifier
# D9C10002241 [Narayanan] - Fix a bug in pattern match where string literals followed by numbers give false results
# ------------------------------------------------------------------------------
# D9B03001821 [zhouc] - 10/21/2002 - test key report from mupip integ
# D9C08002195 [zhouc] - 10/21/2002 - test mupip set with a region list
# D9C09002203 [zhouc] - 10/22/2002 - test VIEW "JNLFLUSH" for a previously unopened region
# D9C08002194 [Narayanan] - GT.M behavior in error trap
# D9C10002236 [Sade] - $NAME causes spurious errors
# C9C11002170 [Narayanan] - Releasing parent lock while holding nested lock causes lock hangs
#-----------------------------------------------------------------------------

echo "v43001d test starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
#
setenv subtest_list_common ""
setenv subtest_list_replic ""
setenv subtest_list_non_replic "D9B12001998 D9C10002241 D9B03001821 D9C08002195 D9C09002203 D9C08002194 D9C10002236"
setenv subtest_list_non_replic "$subtest_list_non_replic C9C11002170"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "v43001d test DONE."
