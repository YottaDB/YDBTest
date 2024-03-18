#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1 255 1024 2048

# This test checks $trestart and signals TP restarts inside trigger logic.
# And intends to stop at $trestart=2. But at that point, PROBLKSPLIT optimization kicks in
# and results in one more restart. But the test logic expects the trigger to commit at
# $trestart=2. Therefore, disable the PROBLKSPLIT logic in this test.
$MUPIP set -problksplit=0 -reg "*" >& mupip_set_problksplit.out

$gtm_exe/mumps -run dztriggerintp > dztriggerintp.outx
echo Passing `$grep -c PASS dztriggerintp.outx`
echo Failing `$grep -c FAIL dztriggerintp.outx`
$gtm_exe/mumps -run onlydztrigintxn
$gtm_tst/com/dbcheck.csh -extract
