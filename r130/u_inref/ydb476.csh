#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# This tests $ZSIGPROC with the named signal string as second argument


echo "\nTesting ZSigproc with invalid string signal name as second argument"
$ydb_dist/yottadb -r invalidsignamelookup^ydb476

echo "\nTesting ZSigproc with valid string signal name as second argument"
echo "Second argument as SIGUSR1"
$ydb_dist/yottadb -r zsigprocint "SIGUSR1"
echo "\nSecond argument as 10"
$ydb_dist/yottadb -r zsigprocint 10
echo "\nSecond argument as string 10"
$ydb_dist/yottadb -r zsigprocint "10"
echo "\nSecond argument as usr1"
$ydb_dist/yottadb -r zsigprocint "usr1"
echo "\nCompleted\n\n"

