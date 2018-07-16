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
# Using .outx because expecting a warning about an argumentless MUPIP RUNDOWN
echo "# Running argumentless MUPIP RUNDOWN and checking syslog"
echo ""
$MUPIP RUNDOWN >& rundown.outx
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
echo "# Syslog message:"
$grep "process id" getoper.txt |& sed 's/.*%YDB-I-MURNDWNARGLESS/%YDB-I-MURNDWNARGLESS/'
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
