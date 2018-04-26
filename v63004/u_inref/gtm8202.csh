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

setenv gtm_test_jnl SETJNL
setenv test_specific_gde $gtm_tst/$tst/inref/gtm8202.gde #adds 2 names: jake to DEFAULT, and zack to TEST

echo "#Create 2 database files for 2 regions, mumps.dat for DEFAULT and test.dat for TEST"
$gtm_tst/com/dbcreate.csh mumps 2 > dbcreate_log.txt

echo "#calls gtm8202.m to set variables"
$ydb_dist/mumps -run gtm8202 > gtm8202.m.log

echo "#  journal extract -SEQNO=0,1,~2 across a single region"
$MUPIP journal -forward -extract=./singleReg.mjf -seqno=0,1,~2 "mumps.mjl"

echo "#  search extract file for set variables"
cat singleReg.mjf | grep "jake(" | awk -F '\\' '{ print $6 " " $11 }'
cat singleReg.mjf | grep "zack(" | awk -F '\\' '{ print $6 " " $11 }'

echo "#  journal extract -SEQNO=~1,2,~3,4  across multiple regions"
echo "#  expected to create error for nonrep"
$MUPIP journal -forward -extract=./multiReg.mjf -seqno=~1,2,~3,4 "*"

echo "#  search extract file for set variables"
cat multiReg.mjf | grep "jake(" | awk -F '\\' '{ print $6 " " $11 }'
cat multiReg.mjf | grep "zack(" | awk -F '\\' '{ print $6 " " $11 }'

$gtm_tst/com/dbcheck.csh >> dbcreate_log.txt



