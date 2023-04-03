#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
# mupip_load_V4  [Hemani]  Test load of longname globals  V4 database. Should load with truncated values.
# gtm7208u	 [base]    Very long lock subscripts cause an error in UTF-8 mode.
# gtm7208m	 [base]    Very long lock subscripts cause an error in M mode.
#####################################################

echo "LONGNAME test starts ..."
setenv maxlen 31

setenv subtest_list_common     ""
setenv subtest_list_non_replic "xtrnsc passparameter tstart objtest litpool_stress rout_label mupip lock dse variable isv"
setenv subtest_list_non_replic "$subtest_list_non_replic mbadlabels mbadvarname mupip_load_V4 gtm7208m"
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
	setenv subtest_exclude_list "$subtest_exclude_list objtest mupip_load_V4"
else if ("suse" == $gtm_test_linux_distrib) then
	# Disable "objtest" subtest on SUSE Linux until r1.40 is released as the only prior release at this
	# point on the SUSE systems is r1.36 which has the same object format as the current master branch of YDB.
	# Once r1.40 is released and "gtm_curpro" is changed, the "longname" test will fail on SUSE boxes and
	# will require the below "if" block to be removed.
	if ($?gtm_curpro) then
		if ($gtm_curpro == "V63014_R138") then
			setenv subtest_exclude_list "$subtest_exclude_list objtest"
		endif
	endif
endif
#On platforms that don't have a V4 version, disable the subtests that rely on V4 versions
if ($?gtm_platform_no_V4) then
	setenv subtest_exclude_list "$subtest_exclude_list mupip_load_V4"
endif
$gtm_tst/com/submit_subtest.csh
echo "LONGNAME test done."
