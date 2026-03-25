#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that setting BLKS_TO_UPGRADE=0 sets FULLY_UPGRADED=FALSE"
$gtm_tst/com/dbcreate.csh mumps

echo "# First, check when BLKS_TO_UPGRADE is not 0"
echo "# Using [dse CHANGE -FILEHEADER -BLKS_TO_UPGRADE=25]"
$gtm_dist/dse CHANGE -FILEHEADER -BLKS_TO_UPGRADE=25
$gtm_dist/dse dump -FILEHEADER -ALL >& dump.txt
echo "# In this case, we expect fully upgraded to be FALSE."
grep "is Fully Upgraded" dump.txt
echo
echo "# Next, check when BLKS_TO_UPGRADE is 0."
echo "# Using [dse CHANGE -FILEHEADER -BLKS_TO_UPGRADE=0]"
$gtm_dist/dse CHANGE -FILEHEADER -BLKS_TO_UPGRADE=0
$gtm_dist/dse dump -FILEHEADER -ALL >& dump1.txt
echo "# In this case, we expect fully upgraded to be TRUE."
grep "is Fully Upgraded" dump1.txt
