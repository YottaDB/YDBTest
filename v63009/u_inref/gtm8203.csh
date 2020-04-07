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

echo "# Starting from V6.3-009 MUPIP REORG -TRUNCATE supports -KEEP=|blocks|percent%"

$gtm_tst/com/dbcreate.csh mumps

echo "# Using -KEEP without percentage"
$gtm_dist/mupip REORG -TRUNCATE -KEEP=85

echo "# Using -KEEP with percentage"
$gtm_dist/mupip REORG -TRUNCATE -KEEP=85%

$gtm_tst/com/dbcheck.csh
