#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that LOCK with timeout of 0 always returns a unowned lock
#
#

echo '# Test that LOCK with timeout of 0 always returns a unowned lock'

$gtm_tst/com/dbcreate.csh mumps

# run the driver
$gtm_dist/mumps -run ydb438

$gtm_tst/com/dbcheck.csh
