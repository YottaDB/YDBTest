#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# The code for GTM9321 was merged into V63013. No test was created for it but the v60000/gtm7277
# test was fixed to test GTM9321 changes.
# This test (v63014/gtm9321) is slightly different and adds value to the testing system.

echo '# This test checks that $ORDER(<indirection>,<literal>) maintains the correct $REFERENCE value'
echo ''
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo ''
echo '# Drive gtm9321 test routine'
$gtm_dist/mumps -run gtm9321
echo ''
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
