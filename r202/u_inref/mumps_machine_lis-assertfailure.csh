#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "###########################################################################################################"
echo '# Test that MUMPS -MACHINE -LIS does not assert fail if more than 128 errors (test of YDB@4d509b3e)'
echo "###########################################################################################################"

echo '# Below is a test case from the commit message of YDB@4d509b3e'
echo '# Generate M program [test.m] with 129 compile time errors'
set backslash_quote
$gtm_dist/mumps -run %XCMD 'for i=1:1:129 write " s x=\'a\'",!' > test.m
echo '# Run [mumps -machine -lis=test.lis test.m]'
echo '# We expect lots of SPOREOL errors followed by ZLINKFILE and ZLNOOBJECT errors'
echo '# Before YDB@4d509b3e, we used to see assert failures (instead of ZLINKFILE/ZLNOOBJECT) with a Debug build of YottaDB'
$gtm_dist/mumps -machine -lis=test.lis test.m

