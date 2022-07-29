#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test for GTM-9313 - Test that $ORDER() with a subscripted variable and a subscript is a boolean'
echo '# expression that references a global variable and has a literal second argument returns the correct'
echo '# value. Prior to V63013, this test returns invalid results causing the test to fail fairly quickly'
echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Drive gtm9313 test routine'
$gtm_dist/mumps -run gtm9313
echo
echo "# Verify database we (very lightly) used"
$gtm_tst/com/dbcheck.csh
