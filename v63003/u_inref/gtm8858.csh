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
# Shows improved available information in cases of apparent database integrity issues
#

# Disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
mkdir backup
$MUPIP Backup Default backup >& backup.out


echo "# Changing block size to trigger a DBKEYMN Error"
$DSE change -block=1 -bsiz=1000
$MUPIP Integ -region default
$DSE integ -block=1
rm mumps.dat
cp backup/mumps.dat mumps.dat
echo "# -------------------------------------------------------------------------------------------------------"

echo "# Changing level to trigger a DBROOTBURN Error"
$DSE change -block=1 -level=0 >& l.out
$MUPIP Integ -region default
$DSE integ -block=1
rm mumps.dat
cp backup/mumps.dat mumps.dat
echo "# -------------------------------------------------------------------------------------------------------"
echo "# Writing a global variable with a null subscript and then changing null_subscripts to false to trigger a NULLSUBSC Error"
$DSE change -file -null_subscripts=true
$ydb_dist/mumps -run ^%XCMD 'set ^X("")=1'
$DSE change -file -null_subscripts=false
$MUPIP Integ -region default
$DSE integ -block=3
rm mumps.dat
cp backup/mumps.dat mumps.dat
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
