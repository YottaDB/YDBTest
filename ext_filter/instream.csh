#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
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
setenv subtest_list_common ""
setenv subtest_list_common "$subtest_list_common basic"
setenv subtest_list_common "$subtest_list_common notalive"
setenv subtest_list_common "$subtest_list_common badconv"
setenv subtest_list_common "$subtest_list_common stress"
setenv subtest_list_common "$subtest_list_common multimods"
setenv subtest_list_common "$subtest_list_common badconv2"
setenv subtest_list_common "$subtest_list_common badconv4"
setenv subtest_list_common "$subtest_list_common bigtrans"
setenv subtest_list_common "$subtest_list_common many_nulls"
setenv subtest_list_common "$subtest_list_common read_timeout"
setenv subtest_list_non_replic ""
setenv subtest_list_replic ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""

if ( "TRUE" == $gtm_test_unicode_support ) setenv subtest_list "$subtest_list ubasic"

$gtm_tst/com/submit_subtest.csh

echo "ext_filter test DONE."
