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
echo '# Tests that literal indirection does not give a YDB-F-KILLBYSIGSINFO1 error.'
#
echo '# Test first case for when literal evaluates to FALSE.'
#
$ydb_dist/mumps -run test1^ydb258
#
echo '# Test second case for when literal evaluates to TRUE.'
#
$ydb_dist/mumps -run test2^ydb258
