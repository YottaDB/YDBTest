#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
echo "# Attempting to overflow the string pool (Expecting an STPCRIT error first and then an STPOFLOW error)"
$ydb_dist/mumps -run test2^gtm8847 >>& errors.outx
# Need to remove corefile produced by STPOFLOW error
rm core*
cat errors.outx |& $grep STPCRIT |& tail -1
cat errors.outx |& $grep STPOFLOW


echo "# Demonstrating that when zstrpllim<=0 there is no limit on the string pool"
echo "# (A max string error indicates that the string pool will not overflow, since the loop is infinite)"
$ydb_dist/mumps -run test3^gtm8847
setenv gtm_string_pool_limit 10000000
echo "# Changing the gtm_string_pool_limit environment variable"
$ydb_dist/mumps -run test1^gtm8847 $gtm_string_pool_limit

