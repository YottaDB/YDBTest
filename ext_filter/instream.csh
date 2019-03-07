#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ------------------------------------------------------------------------------
echo "ext_filter test starts..."
setenv subtest_list "basic notalive badconv stress multimods badconv2 badconv4 nosectrig bigtrans many_nulls read_timeout"
if ( "TRUE" == $gtm_test_unicode_support ) setenv subtest_list "$subtest_list ubasic"

setenv subtest_exclude_list ""

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list nosectrig"
else if ($?ydb_environment_init) then
	# In a YDB environment (i.e. non-GG setup), we do not have prior versions that are needed
	# by the below subtest. Therefore disable it.
	setenv subtest_exclude_list "$subtest_exclude_list nosectrig"
endif

$gtm_tst/com/submit_subtest.csh

echo "ext_filter test DONE."
