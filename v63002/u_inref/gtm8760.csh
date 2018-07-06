#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Testing a long string as a subscript and a value for global and local variables
# All of these would produce core files in previous versions when the string is at least 32768 characters
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
foreach n (32766 32767 32768 32769)
	echo "# Length of Environment Variable is $n bytes"
	$ydb_dist/mumps -run longstring^gtm8760 $n
	setenv longstring `cat longstring.txt`
	echo "# Testing long string as a value for a global variable"
	$ydb_dist/mumps -run test1^gtm8760
	echo "# Testing long string as a subscript for a global variable"
	$ydb_dist/mumps -run test2^gtm8760
	echo "# Testing long string as a value of a local variable"
	$ydb_dist/mumps -run test3^gtm8760
	echo "# Testing long string as a subscript of a local variable"
	$ydb_dist/mumps -run test4^gtm8760
	echo ""
	echo "-------------------------------------------------------------------------"
	echo ""
end
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
