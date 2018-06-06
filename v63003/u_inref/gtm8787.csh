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
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1>>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif
$MUPIP Set -Region Default -Journal=enable,on,before,file=mumps.mjl >>& jnlcreate.out
if ($status) then
	echo "Journal Create Failed, Output Below"
	cat jnlcreate.out
endif
$ydb_dist/mumps -run ^%XCMD "for i=1:1:10 set ^x(i)=i"
set t = `date +"%b %e %H:%M:%S"`
set pid = `($MUPIP journal -extract='-stdout' -forward mumps.mjl >& output.out)&`
echo $pid
$ydb_dist/mumps -run gtm8787 >>& temp.out
set s = `cat temp.out`
$gtm_tst/com/getoper.csh "$t" "" log.out "" $s

cat log.out |& $grep KILLBYSIG
cat log.out |& $grep NOPRINCIO

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
