#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that $QLENGTH(), $QSUBSCRIPT, and $VIEW("YGVN2GDS") properly support ^#t global references\n'

echo '# Create database\n'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo '###############################\n'

echo '# Test $QLENGTH() with supported/unsupported ^# globals with various subscripts, with and without environments\n'
$gtm_dist/mumps -run qlength^ydb982
echo '###############################\n'

echo '# Test $QSUBSCRIPT() with supported/unsupported ^# globals with various subscripts, with and without environments\n'
$gtm_dist/mumps -run qsubscript^ydb982
echo '###############################\n'

echo '# Test $VIEW("YGVN2GDS") with supported/unsupported ^# globals with various subscripts, with and without environments\n'
$gtm_dist/mumps -run view^ydb982
echo '###############################\n'

echo '# Check database integrity'
$gtm_tst/com/dbcheck.csh >>& dbcreate.out
