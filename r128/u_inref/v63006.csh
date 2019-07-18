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
#

echo '# Test that causing >32 lock collisions during a table resize does not fail the >32 collisions assert'

$gtm_tst/com/dbcreate.csh mumps

$ydb_dist/mumps -run v63006

$gtm_tst/com/dbcheck.csh

