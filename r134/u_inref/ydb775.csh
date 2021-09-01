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

echo "#################################################################################################"
echo "###### Test that LOCKS obtained inside TSTART/TCOMMIT are correctly released on TRESTART ########"

$gtm_tst/com/dbcreate.csh mumps

echo "# --------------------------------"
echo "# Test 1 : Single process"
echo "# --------------------------------"
$ydb_dist/yottadb -run singleproc^ydb775
echo "# --------------------------------"
echo "# Test 2 : Multiple processes"
echo "# --------------------------------"
$ydb_dist/yottadb -run multiproc^ydb775

$gtm_tst/com/dbcheck.csh
