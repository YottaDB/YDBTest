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
set t = `date +"%b %e %H:%M:%S"`
sleep 1
$MUPIP RUNDOWN
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
$grep "NEED TO FIGURE OUT WHAT MESSAGE IT SENDS" getoper.txt
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
