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

echo "# Starting from V6.3-009 MUPIP REORG now recognizes the commands -NOCOALESCE -NOSPLIT and -NOSWAP"

$gtm_tst/com/dbcreate.csh mumps

echo "# Testing to see if the following qualifiers are recognized"

echo "# Using NOSWAP"
$gtm_dist/mupip REORG -NOSWAP -reg "*"
echo "# Using NOCOALESCE"
$gtm_dist/mupip REORG -NOCOALESCE -reg "*"
echo "# Using NOSPLIT"
$gtm_dist/mupip REORG -NOSPLIT -reg "*"

$gtm_tst/com/dbcheck.csh
