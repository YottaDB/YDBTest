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

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-F132372 - Test the following release note
*****************************************************************

> The replication update process and its helper processes record
> statistics using the STATSDB facility for reporting using
> ^%YGBLSTAT. GT.M reports the WRL, PRG, WFL, and WHE statistics
> as part of the YGBLSTAT output. See the GT.M Administration &
> Operations Guide for more details. Previously, the replication
> update process and its helper processes did not record
> statistics for STATSDB. (GTM-F132372)

Note that we are only testing the appearance, and not verifying
specific, or even non-zero values of these new stats.
CAT_EOF
echo ""

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

$gtm_dist/mumps -run test^gtmf132372

$gtm_tst/com/dbcheck.csh >& dbcheck.out
