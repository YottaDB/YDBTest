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
$echoline
echo "Tests taken from issues YDB#502 and YDB#546 that use boolean literals both with"
echo "and without one or more nested SELECT functions that failed prior to GTM-9181"
echo "but pass with V63010."
echo
echo "In addition to testing boolean literal failures inside SELECT() functions some"
echo "test cases for related issues (YDB#502 and YDB#546) also solved by GTM-9181 are"
echo "included here. These tests had similar examples of boolean literals with some"
echo "also using SELECT() which were fixed by V63010. So this test adds 3 tests from"
echo "those issues as well."
$echoline
$ydb_dist/yottadb -run gtm9181
