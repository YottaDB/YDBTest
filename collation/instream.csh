#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	#
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
	# If this is Alpine Linux with its musl C library, we cannot (yet?) support the chinese character set so disable
	# subtests that depend on it. ##ALPINE_TODO##
	if ("TRUE" == $gtm_test_unicode_support) then
		if (("linux" != "$gtm_test_osname") || ("alpine" != "$gtm_test_linux_distrib")) then
			setenv subtest_list "$subtest_list def_to_chn local_chn col_nct_with_chn test_opers"
		endif
	endif
endif

$gtm_tst/com/submit_subtest.csh
echo "COLLATION test Ends..."
