#! /usr/local/bin/tcsh -f
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


$gtm_tst/com/dbcreate.csh . 1 200
echo "Test variable names will truncate if more than 31 characters"
$GTM << gtm_end1 >>&! smoke.out
 write "do ^smoke",! do ^smoke
gtm_end1
echo "check if the smoke test succeeded"
$grep -E "YDB-E-|FAIL" smoke.out >>&! /dev/null

if ($status == 0) then
	echo "smoke test failed"
	exit(3)
endif
# run the following only when smoke succeeded
$GTM << gtm_end
set local=1
set global=1
write "do ^lotsvar",! do ^lotsvar
set fname="locals.log"
open fname:NEWVERSION
use fname
zwrite
use \$PRINCIPAL
close fname
do ^%G
globals.log
*

halt
gtm_end
#
\cp $gtm_tst/$tst/outref/{locals.out.gz,globals.out.gz} .
$tst_gunzip globals.out
$tst_gunzip locals.out
# On zOS tag the unzip'ped file to ASCII
if ("os390" == ${gtm_test_osname}) then
	\chtag -tc ISO8859-1 globals.out
	\chtag -tc ISO8859-1 locals.out
endif
\diff globals.out globals.log >& globals.dif
if ($status) echo "TEST-E-FAIL there is a diff in the variables, see globals.dif"
\diff locals.out locals.log >& locals.dif
if ($status) echo "TEST-E-FAIL there is a diff in the variables, see locals.dif"

$gtm_tst/com/dbcheck.csh
