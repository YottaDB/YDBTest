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
echo "--------------------------------------------------------------------------------------------"
echo "# Test that executed DSE commands appear as AIMG records after extracting from a journal."
echo "--------------------------------------------------------------------------------------------"

echo "# Set Test to Enable Journaling in dbcreate.csh"
setenv gtm_test_jnl SETJNL

echo ""

echo "# Create a Database"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

# copy the database file
cp mumps.dat copy.dat

echo "# Perform various DSE commands"
$ydb_dist/dse change -block=2 -bsiz=0xFA0
$ydb_dist/dse overwrite -block=2 -data="ydb96" -offset=CA

echo "# Perform a Journal Extract"
$ydb_dist/mupip journal -extract -detail -forward mumps.mjl >>& extr_report.txt

cat mumps.mjf | grep "AIMG" | awk -F\\ '{print "AIMG "$11}'

echo ""
# Restore the copied database file
rm mumps.dat
mv copy.dat mumps.dat
echo "# Check and Close the Database"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif

