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
$gtm_tst/com/dbcreate.csh mumps 2 >>& dbcreate.out
$GDE change -region AREG -file_name="a/a.dat"
rm a.dat
$ydb_dist/mumps -run ^%XCMD 'set ^A=1'
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
