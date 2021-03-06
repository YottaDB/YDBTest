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
#
# Testing valid inputs of -DEFER_TIME for MUPIP SET
#

# Forcing MM, manually setting variables to avoid incompatibilities, rather than letting dbcreate
# set them randomly since MUPIP SET -DEFER_TIME only works with MM
setenv gtm_test_db_format "NO_CHANGE"
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh

echo '# Creating database, setting defer time to 0'
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate1.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate1.out
endif
$MUPIP set -region DEFAULT -defer_time=0
$gtm_tst/com/dbcheck.csh mumps 1 >>& dbcheck1.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck1.out
endif

echo '\n''# Creating database, setting defer time to 2^31-1'
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate2.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate2.out
endif
set x = `$ydb_dist/mumps -run ^%XCMD "write 2**31-1"`
$MUPIP set -region DEFAULT -defer_time=$x
$gtm_tst/com/dbcheck.csh mumps 1 >>& dbcheck2.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck2.out
endif

echo '\n''# Creating database, setting defer time to a random number'
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate3.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate3.out
endif
# Generating a random number between 0 and 2**31-1
set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 $x`
$MUPIP set -region DEFAULT -defer_time=$rand
$gtm_tst/com/dbcheck.csh mumps 1 >>& dbcheck3.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck3.out
endif

echo '\n''# Creating database, setting defer time to -1'
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate4.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate4.out
endif
$MUPIP set -region DEFAULT -defer_time=-1
$gtm_tst/com/dbcheck.csh mumps 1 >>& dbcheck4.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck4.out
endif

echo '\n''# Creating database, setting defer time to -2 (expecting an error)'
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate5.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate5.out
endif
$MUPIP set -region DEFAULT -defer_time=-2
$gtm_tst/com/dbcheck.csh mumps 1 >>& dbcheck5.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck5.out
endif

echo '\n''# Creating database, setting defer time to 2^31(expecting an error)'
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate6.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate6.out
endif
set y = `$ydb_dist/mumps -run ^%XCMD "write 2**31"`
$MUPIP set -region DEFAULT -defer_time=$y
$gtm_tst/com/dbcheck.csh mumps 1 >>& dbcheck6.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck6.out
endif
