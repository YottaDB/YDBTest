#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo '# This test verifies that VIEW/$VIEW() region name is truncated appropriately and gets a VIEWREGLIST error if multiple $VIEW() regions'
echo
echo '# Create 2 databases with one having a max size name (31 char currently)'
setenv test_specific_gde $gtm_tst/$tst/u_inref/gtm9340.gde
$gtm_tst/com/dbcreate.csh mumps 1
echo
echo '# Drive ^gtm9340'
$gtm_dist/mumps -run gtm9340
echo
echo '# Validate DBs'
$gtm_tst/com/dbcheck.csh
