#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test uses DSE to drop the database block size to the minimum 512 bytes.
# For ASYNCIO, the database block size has to be a multiple of the underyling file system block size (usually 4KiB).
# Therefore disables ASYNCIO for this test (as otherwise one would see %YDB-E-DBBLKSIZEALIGN errors).
setenv gtm_test_asyncio 0

$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate_log.out
$gtm_dist/mumps -run gtm8511
$gtm_tst/com/dbcheck.csh >&! dbcheck_log.out
