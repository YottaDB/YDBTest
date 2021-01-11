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

echo '# Test that obtaining 32+ M Locks with same modulo hash value and a zero timeout can be obtained by retrying (internally)'
echo '# after a garbage-collection, a rehash or a resize.'
echo ""
$gtm_tst/com/dbcreate.csh mumps
echo "*** Executing ydb673 ***"
$ydb_dist/yottadb -run ^ydb673
echo "*** Run complete ***"
# Check DBs
$gtm_tst/com/dbcheck.csh
