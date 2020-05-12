#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# %PEEKBYNAME now accepts the path to the directory where gtmhelp.gld and'
echo '# gtmhelp.dat reside as an optional fourth parameter gldpath. If not provided'
echo '# it picks data from $ydb_dist, the default location, which it did not previously'

# Create a directory to temporarily move mumps to prevent dbcreate from renaming
mkdir datbak
$gtm_tst/com/dbcreate.csh mumps
mv mumps.dat mumps.gld datbak/
$gtm_tst/com/dbcreate.csh gtmhelp -key_max_size=22
mv datbak/* .

echo '# This test uses max_key_size as the primary parameter for ^%PEEKBYNAME and'
echo '# verfies that the same output occurs with and without a optional fourth parameter'

echo '# Testing ^%PEEKBYNAME with and without a fourth parameter'
$ydb_dist/yottadb -run gtm9000

$gtm_tst/com/dbcheck.csh mumps
$gtm_tst/com/dbcheck.csh gtmhelp
