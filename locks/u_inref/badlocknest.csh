#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# This test raises a %YDB-E-BADLOCKNEST where appropriate to verify that the error message is working correctly. This is"
echo "# needed because there was previously no test that raised this error message."

$echoline
echo "# Creating a database. Without this step, the test produces a %YDB-E-ZGBLDIRACC because mumps.gld doesn't exist"
$gtm_tst/com/dbcreate.csh mumps

$echoline
echo "# Creating the M code file badlocknest.m that raises the %YDB-E-BADLOCKNEST."
cat >> badlocknest.m << xx
        lock x:\$\$timeout
        quit
timeout()
        lock +y
        quit 0
xx

$echoline
echo "# Run the M code expecting a %YDB-E-BADLOCKNEST"
$ydb_dist/yottadb -run badlocknest

$echoline
$gtm_tst/com/dbcheck.csh
