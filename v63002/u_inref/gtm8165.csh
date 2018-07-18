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
echo "# Setting gtm_tpnotacidtime to .123 seconds"
setenv gtm_tpnotacidtime .123
foreach arg ("write /wait(.999)" 'write /pass(,.999,"handle")' 'write /accept(,.999,"handle")' 'write /tls("client",.999)')
	echo "# Testing write timeout ($arg) greater than .123 (Expect a TPNOTACID message in the syslog)"
	set t = `date +"%b %e %H:%M:%S"`
	sleep 1
	$ydb_dist/mumps -run tpnotacid^gtm8165 $arg
	$gtm_tst/com/getoper.csh "$t" "" getoper.txt
	sleep 1
	echo "# Checking the syslog"
	$grep TPNOTACID getoper.txt |& sed 's/.*%YDB-I-TPNOTACID/%YDB-I-TPNOTACID/' |& sed 's/$TRESTART.*//' |& $grep gtm8165
	echo ""
	echo "--------------------------------------------------------------------------------"
	echo ""
end
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
