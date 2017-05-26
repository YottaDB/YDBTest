#!/usr/local/bin/tcsh -f

# disable implicit mprof testing for this test to avoid failures do
# to slower performance
unsetenv gtm_trace_gbl_name

echo "profile test starts..."

setenv subtest_list_common "profile_v734 "
setenv subtest_list_non_replic ""
setenv subtest_list_replic ""
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

set hostn = $HOST:r:r:r
if ((("snail" == "$hostn") || ("turtle" == "$hostn"))) then
		setenv subtest_exclude_list "profile_v734"
endif

$gtm_tst/com/submit_subtest.csh
echo "profile test DONE."
