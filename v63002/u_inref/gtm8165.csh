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
# writeslashtls^gtm8165 requires a port number to communicate. So allocate one from the test system framework.
source $gtm_tst/com/portno_acquire.csh >>& portno.out	# portno env var will be set to the alloted portno
echo "# Setting gtm_tpnotacidtime to .123 seconds"
setenv gtm_tpnotacidtime .123
setenv timeout 1
foreach arg("writeslashwait" "writeslashpass" "writeslashaccept" "writeslashtls" "locktimeout" "opentimeout")
	echo "# Testing command timeout ($arg) greater than .123 (Expect a TPNOTACID message in the syslog)"
	set t = `date +"%b %e %H:%M:%S"`
	$ydb_dist/mumps -run $arg^gtm8165
	$gtm_tst/com/getoper.csh "$t" "" getoper1_$arg.txt
	# Sleep included to avoid 1 iteration reading the message from a previous one
	sleep 1
	echo "# Checking the syslog"
	$grep TPNOTACID getoper1_$arg.txt |& sed 's/.*%YDB-I-TPNOTACID/%YDB-I-TPNOTACID/' |& sed 's/$TRESTART.*//' |& $grep gtm8165
	echo ""
	echo "---------------------------------------------------------------------------------"
	echo ""
end
setenv timeout 0
foreach arg("writeslashwait" "writeslashpass" "writeslashaccept" "writeslashtls" "locktimeout" "opentimeout")
	echo "# Testing command without a specified timeout ($arg), Expect a TPNOTACID message in the syslog still"
	set t = `date +"%b %e %H:%M:%S"`
	(($ydb_dist/mumps -run $arg^gtm8165 >& tpnotacid_$arg.out)&;echo $!>&pid.out)>& bckg.out
	set pid=`cat pid.out`
	$gtm_tst/com/getoper.csh "$t" "" getoper2_$arg.txt "" "TPNOTACID"
	kill -9 $pid
	if ( "writeslashwait" != $arg && "opentimeout" != $arg) then
		set pid2=`cat $arg.txt`
		kill -9 $pid2
	endif
	# Sleep included to avoid 1 iteration reading the message from a previous one
	sleep 1
	$grep TPNOTACID getoper2_$arg.txt |& sed 's/.*%YDB-I-TPNOTACID/%YDB-I-TPNOTACID/' |& sed 's/$TRESTART.*//' |& $grep gtm8165
	echo ""
	echo "---------------------------------------------------------------------------------"
	echo ""
end

$gtm_tst/com/portno_release.csh	# Release the portno allocated above by portno_acquire.csh
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
