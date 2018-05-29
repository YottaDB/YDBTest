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
# Test that a line length greater than 8192 bytes produces a LSEXPECTED warning
#

# Forcing MM, manually setting variables to avoid incompatibilities, rather than letting dbcreate
# set them with RNG
setenv gtm_test_db_format "NO_CHANGE"
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh

echo '# Creating database, setting defer time to 0'
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -region DEFAULT -defer_time=0
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt

echo '\n''# Creating database, setting defer time to 2^31-1'
$gtm_tst/com/dbcreate.csh mumps 1
set x = `$ydb_dist/mumps -run ^%XCMD "write 2**31-1"`
$MUPIP set -region DEFAULT -defer_time=$x
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt

echo '\n''# Creating database, setting defer time to a random number'
$gtm_tst/com/dbcreate.csh mumps 1
# Generating a random number between 0 and 2**31-1
set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 $x`
$MUPIP set -region DEFAULT -defer_time=$rand
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt

echo '\n''# Creating database, setting defer time to -1'
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -region DEFAULT -defer_time=-1
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt

echo '\n''# Creating database, setting defer time to -2 (expecting an error)'
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -region DEFAULT -defer_time=-2
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt

echo '\n''# Creating database, setting defer time to 2^31(expecting an error)'
$gtm_tst/com/dbcreate.csh mumps 1
set y = `$ydb_dist/mumps -run ^%XCMD "write 2**31"`
$MUPIP set -region DEFAULT -defer_time=$y
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt





