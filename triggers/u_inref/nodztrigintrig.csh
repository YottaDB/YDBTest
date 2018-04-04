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

$gtm_tst/com/dbcreate.csh mumps 1 255 1024 2048
$gtm_exe/mumps -run nodztrigintrig >&! nodztrigintrig.outx
# grep for failures but ignore STACKCRIT and ETRAP errors
$grep 'YDB-' nodztrigintrig.outx | $grep -vE 'STACKCRIT|ERRWETRAP'
echo Passing `$grep -c PASS nodztrigintrig.outx`
echo Failing `$grep -c FAIL nodztrigintrig.outx`
$gtm_tst/com/dbcheck.csh -extract
