#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#
# List of tests whose code got fixed in V53003 but a test got added only in V54000
#----------------------------------------------------------------------------------
# C9I12003060 [Narayanan] LKE SHOW -OUTPUT prints appropriate error if not able to open file
#
# List of tests for code fixed in V53004A
#-------------------------------------------
# D9J07002728 [SteveJ]    Make sure zcompile releases lock on object file if there's a compile error
# D9J07002729 [SteveJ]    Test that "mumps -list routine.m" where routine.m has missing label syntax errors doesn't core
#
# List of tests for code fixed in V54000
#-------------------------------------------
# D9D08002354 [Roger]     $GET(glvn, lcl2) does not work right when lcl2 is undefined
# C9F07002746 [Roger]     $INCR on an undefined global does not force alphanumeric string to numeric
# C9D08002390 [groverh]   Get C stack trace of blocking processes in case of these messages:
#			  BUFOWNERSTUCK, INTERLOCK_FAIL, JNLPROCSTUCK, MAXJNLQIOLOCKWAIT and WRITERSTUCK
# C9J09003198 [Mikec]     Signal 11 caused by invalid database owner or group
# C9J09003199 [johnsons]  Check for memory corruption in dse, lke, and mupip caused by cli_gettoken()
# D9I09002699 [s7mj]  	  Test to check JNLWAIT error after issuing view JNLWAIT
# C9J06003145 [s7mj]      gtmsecshr sholud error out if the $gtm_tmp value more than the system specific sun_path size
# C9J08003178 [s7kk]	  GTM should issue REQRUNDOWN error if shmid stored in file header does not exist
# C9D06002318 [shaha]	  ZGoto autozlinking fixed
# C9J11003211 [s7kk]	  PROFILE requires previous non-standard exclusive kill
# C9J11003214 [Narayanan] Not validating clue in final retry causes TPFAIL GGGG errors in V53004
# C9J04003108 [SteveE]    Test for save/restore $ECODE
#
# List of tests for code fixed in V54000A
#-------------------------------------------
# D9K02002754 [Roger]     GDE should not lose ranges constructed of maximum length names
# D9K02002755 [SteveE]	  $Quit not evaluated correctly
# D9D10002376 [SteveE/maimoneb]  Verify LVNULLSUBS is comprehensively handled
# D9K03002759 [SteveE/maimoneb]  Verify LVNULLSUBS and UNDEF work together
# D9804000754 [Roger/maimoneb] Verify $RANDOM() doesn't fail for large values
#-------------------------------------------------------------------------------------

echo "v54000 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "D9J07002728 D9J07002729 D9D08002354 C9F07002746 C9D08002390 C9J09003198 C9J09003199 D9I09002699"
setenv subtest_list_non_replic "${subtest_list_non_replic} C9I12003060 C9J06003145 C9D06002318 C9J11003211 C9J08003178 C9J11003214"
setenv subtest_list_non_replic "${subtest_list_non_replic} C9J04003108 D9K02002754 D9K02002755 D9D10002376 D9K03002759 D9804000754"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list ""

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list C9J09003198"
endif

# If IGS is not available, filter out tests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list C9J09003198 C9J06003145"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v54000 test DONE."
