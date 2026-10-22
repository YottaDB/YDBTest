#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
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

set testlist = "writeslashwait writeslashpass writeslashaccept writeslashtls locktimeout opentimeout"

# writeslashtls^gtm8165 requires a port number to communicate. So allocate one from the test system framework.
source $gtm_tst/com/portno_acquire.csh >>& portno.out	# portno env var will be set to the alloted portno
echo "# Setting gtm_tpnotacidtime to .123 seconds"
setenv gtm_tpnotacidtime .123
setenv timeout 1
foreach arg ($testlist)
	echo "# Testing command timeout ($arg) greater than .123 (Expect a TPNOTACID message in the syslog)"
	set t = `date +"%b %e %H:%M:%S"`
	# We want to run the mumps -run command in the foreground but in order to avoid TPNOTACID messages from other
	# concurrently running tests from affecting this test, we note down the pid and search for messages only from that pid.
	# Hence the backgrounding (to note down the pid) and later wait for the pid to die before searching for messages in syslog.
	($ydb_dist/mumps -run $arg^gtm8165 >& tpnotacid1_$arg.out &; echo $! >& pid1_$arg.out) >& bckg1_$arg.out
	set pid = `cat pid1_$arg.out`
	# Wait for 300 seconds (5 minutes) below as we have seen sometimes the default 60 second (1 minute) wait is not enough.
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
	cat tpnotacid1_$arg.out
	$gtm_tst/com/getoper.csh "$t" "" getoper1_$arg.txt
	# Sleep included to avoid 1 iteration reading the message from a previous one
	sleep 1
	echo "# Checking the syslog"
	$grep "MUMPS\[\<$pid\>\].*TPNOTACID" getoper1_$arg.txt |& sed 's/.*%YDB-I-TPNOTACID/%YDB-I-TPNOTACID/' |& sed 's/$TRESTART.*//'
	echo ""
	echo "---------------------------------------------------------------------------------"
	echo ""
end
setenv timeout 0
foreach arg ($testlist)
	echo "# Testing command without a specified timeout ($arg), Expect a TPNOTACID message in the syslog still"
	set t = `date +"%b %e %H:%M:%S"`
	($ydb_dist/mumps -run $arg^gtm8165 >& tpnotacid2_$arg.out &; echo $! >& pid2_$arg.out) >& bckg2_$arg.out
	set pid = `cat pid2_$arg.out`
	$gtm_tst/com/getoper.csh "$t" "" getoper2_$arg.txt "" "MUMPS\[\<$pid\>\].*TPNOTACID"
	if (("writeslashtls" == $arg) && ("TRUE" == "$gtm_test_tls")) then
		# With TLS on, the TLS handshake completes, so this process finishes on its own after its child
		# (tlschild^gtm8165) does. With TLS off, the child has no TLS configuration and does not answer the
		# handshake, so the else below kills both.
		$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
	else
		kill -9 $pid
		if ( "writeslashwait" != $arg && "opentimeout" != $arg) then
			set pid2=`cat $arg.txt`
			kill -9 $pid2
		endif
	endif
	# Sleep included to avoid 1 iteration reading the message from a previous one
	sleep 1
	$grep "MUMPS\[\<$pid\>\].*TPNOTACID" getoper2_$arg.txt |& sed 's/.*%YDB-I-TPNOTACID/%YDB-I-TPNOTACID/' |& sed 's/$TRESTART.*//'
	echo ""
	echo "---------------------------------------------------------------------------------"
	echo ""
end

$gtm_tst/com/portno_release.csh	# Release the portno allocated above by portno_acquire.csh
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
