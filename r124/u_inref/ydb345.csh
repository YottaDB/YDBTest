#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "-------------------------------------------------------------------------------------------------------------------------------"
echo "# Tests that opening a PIPE device issues a STDERRALREADYOPEN error if STDERR is specified and points to an already open device"
echo "-------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo 'Run test case x.m. Previously produces unpredictable results as $PRINCIPAL is used in the STDERR.'
$ydb_dist/mumps -run x^ydb345

echo ""
echo 'Run test case y.m. Previously closes $PRINCIPAL automatically and incorrectly if the PIPE device was closed.'
$ydb_dist/mumps -run y^ydb345

echo ""
echo 'Run Test case z.m. Previously $PRINCIPAL would become READ-ONLY device when used as the STDERR for the OPEN of a PIPE.'
$ydb_dist/mumps -run z^ydb345
