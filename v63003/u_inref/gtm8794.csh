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
# Tests copies of a database file made while a MUPIP FREEZE -ONLINE -ON is in effect can
# be used on the same system by performing a MUPIP RUNDOWN -OVERRIDE and a MUPIP FREEZE -OFF on the copy
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
echo "# Creating temp folder, making copies of all relevant files for temp folder, switching to temp folder"
mkdir temp
cp mumps* temp/
cd temp
rm mumps.mjl
echo ""
echo "# Performing Rundown on mumps.dat in temp folder"
$MUPIP RUNDOWN -OVERRIDE -FILE mumps.dat

echo ""
echo "# Turning off Freeze for DEFAULT (will act on database file in temp)"
$MUPIP FREEZE -OFF DEFAULT

echo "# Updating Database"
# Reassigning jnl file for the database to be in the temp folder (Randomly set to before/nobefore by the tests framework)
$MUPIP SET -REGION DEFAULT -JOURNAL=disable -REPLICATION=OFF>&jnl.outx
if($status) then
	echo "Bad MUPIP SET"
endif
$MUPIP SET -REGION DEFAULT $tst_jnl_str >&jnl.outx
if ($status) then
	echo "Bad MUPIP SET"
endif

echo '# set ^X=1  zwrite ^X'
$ydb_dist/mumps -run ^%XCMD "set ^X=1  zwrite ^X"
cd ..
# Need to unfreeze initial region so dbcheck can work
$MUPIP FREEZE -OFF "*" >>& Freeze.out
$gtm_tst/com/dbcheck.csh>&check.out
if ($status) then
	echo "dbcheck failed"
endif

