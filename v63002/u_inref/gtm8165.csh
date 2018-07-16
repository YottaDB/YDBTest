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
echo '# Testing write timeout greater than $gtm_tpnotacidtime (Expect a TPNOTACID message in the syslog)'
echo ""
foreach arg ("wait" "tls" "accept" "pass")
	echo "# Testing a timed write /$arg"
	set t = `date +"%b %e %H:%M:%S"`
	sleep 1
	$ydb_dist/mumps -run tpnotacid^gtm8165 $arg
	$gtm_tst/com/getoper.csh "$t" "" getoper.txt
	echo "# Checking the syslog"
	$grep TPNOTACID getoper.txt |& sed 's/.*%YDB-I-TPNOTACID/%YDB-I-TPNOTACID/' |& sed 's/$TRESTART.*//'
	echo ""
	echo "--------------------------------------------------------------------------------"
	echo ""
end
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
