#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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
setenv subtest_list "conv_utf8 gbl_utf8 rtn_utf8 utf2hex "
setenv subtest_list "date testdate conv math gbl rtn $subtest_list"
$gtm_tst/com/submit_subtest.csh
echo "mpt_extra test DONE."
