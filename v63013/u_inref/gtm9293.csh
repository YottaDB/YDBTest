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

echo "# This test checks that empty string results from argument indirection,"
echo "# when the command would accept such an argument, are accepted."
echo "# Previously they were rejected as an invalid expression."

echo "# WRITE, XECUTE, KILL and DO commands are tested."
echo "# There is no output for this test, just a new line which is part of" 
echo "# the WRITE test case."

$ydb_dist/yottadb -run write^gtm9293
$ydb_dist/yottadb -run xecute^gtm9293
$ydb_dist/yottadb -run kill^gtm9293
$ydb_dist/yottadb -run do^gtm9293
