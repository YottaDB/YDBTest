#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '---------------------------------------------------------------------'
echo '######## Test various code issues identified by fuzz testing ########'
echo '---------------------------------------------------------------------'

echo ""
echo '# Test $CHAR(0) in vector portion of $ZTIMEOUT does not SIG-11'
$ydb_dist/yottadb -run %XCMD 'S $ZTim=":"_$CHAR(0)'

echo ""
echo '# Test LVUNDEF error is issued if $ZTIMEOUT is set to an undefined lvn'
$ydb_dist/yottadb -run %XCMD 'S $ZTim=xyz'

echo ""
echo '# Test no memory leaks when invalid M code is specified in $ZTIMEOUT'
$ydb_dist/yottadb -run ydb828

