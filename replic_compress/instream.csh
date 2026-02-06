#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# --------------------------------------------------------------------------------------------------------------
# Tests for replication pipe compression changes
# --------------------------------------------------------------------------------------------------------------
# cmplvl_qual		Test CMPLVL qualifier
# repltrans2big		Test that REPLTRANS2BIG error is issued by receiver server
# zlib_not_found	(obsolete) Test that LD_LIBRARY_PATH/LIBPATH control whether GT.M finds zlib library or not
# --------------------------------------------------------------------------------------------------------------
#
echo "replic_compress test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic ""
setenv subtest_list_replic "$subtest_list_replic cmplvl_qual "
setenv subtest_list_replic "$subtest_list_replic repltrans2big"
setenv subtest_list_non_replic ""
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

$gtm_tst/com/submit_subtest.csh
echo "replic_compress test DONE."
