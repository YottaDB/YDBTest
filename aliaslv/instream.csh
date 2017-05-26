#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# -------------------------------------------------------------------------------------
# Alias support testing -- added as part of C9I02-002957 and GTM-8064
# -------------------------------------------------------------------------------------
#
echo "aliaslv test START."
# disable implicit mprof testing to prevent failures due to extra memory footprint;
# see <mprof_gtm_trace_glb_name_disabled> for more detail
unsetenv gtm_trace_gbl_name
setenv subtest_list "alsbasic alserrors alsspecexamples alstptests alsxnewtests alszwrtests"
setenv subtest_list "$subtest_list alslvgcol alststartvar alskillstar alssymvalinherit"
setenv subtest_list "$subtest_list alsmisctests"

# Filter out alslvgcol test if running in dbg as that will fail with differing count of garbage collected entries
# because it expects VIEW "LV_GCOL" to be called only when the test calls it whereas in dbg mode, als_lvval_gc
# is automatically called once-in-a-while in gtm_fetch.
if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "alslvgcol"
endif

$gtm_tst/com/submit_subtest.csh
echo "aliaslv test DONE."
