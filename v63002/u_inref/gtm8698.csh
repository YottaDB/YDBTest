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
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Changing the region to AUTODB and setting the file to an invalid .dat file"
echo "# This will trigger an error when we attempt to update the database"
$GDE change -segment DEFAULT -file_name="a/a.dat" >& changefile.out
$GDE change -region DEFAULT -AUTODB >& autodb.out
rm mumps.dat
set t = `date +"%b %e %H:%M:%S"`
sleep 1
echo ""
echo "# Attempting to update the database"
$ydb_dist/mumps -run ^%XCMD 'set ^A=1'
echo "# Checking the syslog"
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
$grep "MUCREFILERR" getoper.txt |& sed 's/.*%YDB-E-MUCREFILERR/%YDB-E-MUCREFILERR/'|& sed 's/%YDB-E-DBOPNERR.*//'
# Fixing everything so the dbcheck can operate appropriately
$GDE change -segment DEFAULT -file_name="mumps.dat" >& fix.out
$ydb_dist/mumps -run ^%XCMD 'set ^A=1' >& setvar.out
$gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
