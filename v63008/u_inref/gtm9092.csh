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
$gtm_tst/com/dbcreate.csh mumps 2

echo "# IN^%YGBLSTAT returns a value of 1 for TRUE and 0 for FALSE whether or not"
echo "# there are sharing statistics for the given process. If the process is invalid"
echo "# or there is no sharing for a region then it returns an empty string. Also if the"
echo "# region field is left empty or an asterisk it will return true if there is any"
echo "# sharing for any process, otherwise it will return false"

$ydb_dist/mumps -run gtm9092
$gtm_tst/com/dbcheck.csh
