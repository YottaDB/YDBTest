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
source $gtm_tst/com/gtm_test_setbgaccess.csh
$gtm_tst/com/dbcreate.csh mumps 1>&create.out
if ($status) then
	echo "create failed"
endif
$MUPIP SET -region DEFAULT -journal=enable,on,before -replication=on
$MUPIP FREEZE -ON -ONLINE DEFAULT
echo ""

$ydb_dist/mumps -run ^%XCMD "set ^X=1"
sleep 1
$MUPIP Journal -Extract -Forward mumps.mjl
cat mumps.mjf |& $grep X= |& $tst_awk -F '\\' '{print $1,"/",$11}'

echo ""
$MUPIP FREEZE -OFF DEFAULT
$gtm_tst/com/dbcheck.csh>&check.out
if ($status) then
	echo "close failed"
endif

