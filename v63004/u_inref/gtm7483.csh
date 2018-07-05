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

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps > db_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db_log.txt
endif
echo ""

#$ydb_dist/mumps -run %XCMD ';write:$zfind(%l,"=") $zpiece(%l,"\",3),!;'
#$DSE add -b=2 -r=1 -key=^TheMaximumLengthOfAKeyIsThirtyTwoCharacters -data="this data is arbitrary"

#echo "# Change maximum key size to 4"
#$DSE change -F -KEY_MAX_SIZE=4
#echo ""
#
echo "# Call gtm7483.m to set variables with sequentially longer keys"
$ydb_dist/mumps -run gtm7483 > gtm7483_m.log
echo ""
$DSE add -block=2 -rec=1 -key=^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -data="\04\00\00\00"
#
#echo "# Perform mupip extract to display the DB's set variables"
#$MUPIP extract extract.glo
#echo ""

echo "# Checking for DBKEYMX"
$MUPIP INTEG -file "mumps.dat" >>& text.txt
$grep "DBKEYMX" text.txt
echo ""

echo "# Perform mupip integ"
$MUPIP INTEG -file "mumps.dat"
echo ""

echo "# Check the DB"
$gtm_tst/com/dbcheck.csh > db_chk_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db_chk_log.txt
endif
