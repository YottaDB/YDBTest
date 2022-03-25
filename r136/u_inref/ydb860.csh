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

$gtm_tst/com/dbcreate.csh mumps

echo '---------------------------------------------------------------------'
echo '######## Test various code issues identified by fuzz testing ########'
echo '---------------------------------------------------------------------'

echo ""
echo "------------------------------------------------------------"
echo '# Test OPEN of a SOCKET device with a long LISTEN device parameter works fine'
echo '# This used to previously (before YDB@98837f3e) fail with a SIG-11/Assert'
echo '# Expecting ADDRTOOLONG error in below output'
echo "------------------------------------------------------------"
set base = "ydb860opensocketlisten"
cat > $base.m << CAT_EOF
 set sf=\$translate(\$justify("x",128)," ","x")
 open "s":(LISTEN=sf_":LOCAL")::"SOCKET"
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
$gtm_tst/com/dbcheck.csh
