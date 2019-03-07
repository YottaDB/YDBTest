#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# this tests handles collation itself, so should not be called with collation
echo "COLLATION test Starts..."

setenv subtest_list "def_to_pol pol_to_def"
setenv unicode_testlist ""

if ( $LFE == "E" ) then
	setenv subtest_list "$subtest_list pol_to_pol pol_to_revpol local_col col_nct ylct"
	if (("TRUE" == $gtm_test_unicode_support ) && ($gtm_test_osname != "osf1")) then
		setenv subtest_list "$subtest_list def_to_chn local_chn col_nct_with_chn test_opers"
	endif
endif

$gtm_tst/com/submit_subtest.csh
echo "COLLATION test Ends..."
