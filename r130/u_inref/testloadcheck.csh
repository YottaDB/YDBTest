#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# Verifies if ^hello("one") is set to 1 after performing a mupip load with given file and option
# $1 is file
# $2 is mupip load option
$ydb_dist/yottadb -r ^%XCMD 'kill ^hello("one")'

$ydb_dist/yottadb -r ^%XCMD 'write:$get(^hello("one"),0)="1" "Failed: data already exist"'

echo "\n# mupip load $2 $1"
$ydb_dist/mupip load $2 $1

echo "\n# check if data is loaded"
$ydb_dist/yottadb -r ^%XCMD 'write:$get(^hello("one"),0)="1" "LOAD PASSED"',!

echo "\nDONE"
