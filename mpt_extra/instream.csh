#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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

# ------------------------------------------------------------------------------
# extra tests for percent routines
# ------------------------------------------------------------------------------
#-----------------------------------------------------------------------------

echo "mpt_extra test starts..."
#
if ( "TRUE" == $gtm_test_unicode_support ) then
	setenv unicode_testlist "conv_utf8 gbl_utf8 rtn_utf8 utf2hex "
else
	setenv unicode_testlist ""
endif
setenv subtest_list "date testdate conv math gbl rtn $unicode_testlist "

setenv subtest_exclude_list    ""

if ("arch" == $gtm_test_linux_distrib) then
	# Temporarily disable the below subtest on Arch Linux (ICU 62.1) as there seems to be a regression that causes
	# lower-case/upper-case conversions to return incorrect results. Will be re-enabled once the ICU issue is fixed.
	setenv subtest_exclude_list "$subtest_exclude_list conv_utf8"
endif
$gtm_tst/com/submit_subtest.csh
echo "mpt_extra test DONE."
