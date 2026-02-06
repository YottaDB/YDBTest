#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#####################################################
# C9D03-002250 Support Long Names
# global/local/routine/label/region/segment names
#####################################################
# xtrnsc	 [balaji]  test extrinsic function calls for longnames
# passparameter	 [balaji]  test actualvsformal list parameters & callbyreference with longnames
# tstart	 [balaji]  test tstart to preserve local variables
# objtest	 [balaji]  test compiled obj files across versions
# litpool_stress [kishore] Stress literal pool test using long names
# rout_label	 [zhouc]   Test routine and label names
# mupip 	 [zhouc]   Test MUPIP
# lock 		 [zhouc]   Test locks
# dse 		 [zhouc]   Test DSE
# variable 	 [zhouc]   Test global and local variables
# isv  		 [zhouc]   Test case 12 Intrinsic special variables
# mbadlabels     [nars]    Test bad label names (moved from "manual_tests". originally written by Layek)
# mbadvarname    [nars]    Test bad variable names (moved from "manual_tests". originally written by Layek)
# gtm7208u	 [base]    Very long lock subscripts cause an error in UTF-8 mode.
# gtm7208m	 [base]    Very long lock subscripts cause an error in M mode.
#####################################################

echo "LONGNAME test starts ..."
setenv maxlen 31

setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic xtrnsc"
setenv subtest_list_non_replic "$subtest_list_non_replic passparameter"
setenv subtest_list_non_replic "$subtest_list_non_replic tstart"
setenv subtest_list_non_replic "$subtest_list_non_replic litpool_stress"
setenv subtest_list_non_replic "$subtest_list_non_replic rout_label"
setenv subtest_list_non_replic "$subtest_list_non_replic mupip"
setenv subtest_list_non_replic "$subtest_list_non_replic lock"
setenv subtest_list_non_replic "$subtest_list_non_replic dse"
setenv subtest_list_non_replic "$subtest_list_non_replic variable"
setenv subtest_list_non_replic "$subtest_list_non_replic isv"
setenv subtest_list_non_replic "$subtest_list_non_replic mbadlabels"
setenv subtest_list_non_replic "$subtest_list_non_replic mbadvarname"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7208m"
setenv subtest_list_replic     ""
if ( "TRUE" == "$gtm_test_unicode_support" ) then
	setenv unicode_testlist "gtm7208u"
	setenv subtest_list_non_replic "$subtest_list_non_replic gtm7208u"
endif
#####################################################
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
#####################################################
setenv subtest_exclude_list ""
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list objtest"
endif
$gtm_tst/com/submit_subtest.csh
echo "LONGNAME test done."
