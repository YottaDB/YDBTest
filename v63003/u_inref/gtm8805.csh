#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
#

# Default used for DSE crit seize, AREG used to dictate order of execution, BREG used as an eventlog
$gtm_tst/com/dbcreate.csh mumps 3>>&dbcreate.out
if ($status) then
	cat dbcreate.out
endif
$ydb_dist/mumps -run gtm8805
$gtm_tst/com/dbcheck.csh>>dbcheck.out
if ($status) then
	cat dbcheck.out
endif
