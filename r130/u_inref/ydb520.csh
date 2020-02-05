#!/usr/local/bin/tcsh -f
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

# This test ensures that alternating between setting $ZT ($ZTRAP) and
# $ET ($ETRAP) is handled correctly. The first test ($ET then $ZT)
# fails with an assert failure on versions that contain this bug.
# The second test ($ZT then $ET) should pass on all versions but
# is included to ensure that both situations are covered by the
# test system.
$gtm_tst/com/dbcreate.csh mumps
echo "Testing ETRAP->ZTRAP->ETRAP->ZTRAP"
$ydb_dist/mumps -r ydb520A
echo "Testing ZTRAP->ETRAP->ZTRAP->ETRAP"
$ydb_dist/mumps -r ydb520B
