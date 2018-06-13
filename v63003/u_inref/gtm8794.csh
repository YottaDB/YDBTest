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
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_jnl SETJNL
$gtm_tst/com/dbcreate.csh mumps 1>&create.out
if ($status) then
	echo "dbcreate failed"
endif
echo "# Setting Freeze ON,ONLINE"
$MUPIP FREEZE -ON -ONLINE DEFAULT
echo ""
mkdir temp
cp mumps.dat temp/mumps.dat
cp mumps.gld temp/mumps.gld
cp mumps.mjl temp/mumps.mjl
cd temp
$MUPIP RUNDOWN -OVERRIDE -FILE mumps.dat

echo ""

$MUPIP FREEZE -OFF "*"


$ydb_dist/mumps -run ^%XCMD "set ^X=1  zwrite ^X"
$ydb_dist/mumps -run ^%XCMD 'write:^X "TEST PASSED"'
$gtm_tst/com/dbcheck.csh>&check.out
if ($status) then
	echo "dbcheck failed"
endif

