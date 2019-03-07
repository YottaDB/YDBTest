#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

echo "# incrgv2 subtest -  increment within TP of global variables that are NOISOLATED"

$gtm_tst/com/dbcreate.csh mumps 1
echo "# Verify incrementing a NOISOLATION variable works (used to fail with GVINCRISOLATION - an error since removed)"
$ydb_dist/mumps -run incrgv2
$gtm_tst/com/dbcheck.csh

echo "# End  of subtest"
