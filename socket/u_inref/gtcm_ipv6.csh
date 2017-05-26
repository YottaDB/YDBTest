#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/portno_acquire.csh >>& portno.out
mkdir server
mkdir client
setenv SERV_SIDE $PWD/server
setenv CLIENT_SIDE $PWD/client
setenv TEST_DIR	$PWD

cd $SERV_SIDE
setenv gtmgbldir mumps.gld
$GDE exit
$MUPIP create
set start_time=0
$gtm_tst/com/GTCM_SERVER.csh $portno $start_time >& gtcm_server_activity.log

cd $CLIENT_SIDE
setenv GTCM_localhost6 $portno
$GDE << gde_eof
	change -s DEFAULT -file=$SERV_SIDE/mumps.dat
	exit
gde_eof
$GTM << gtm_eof
	set ^x="Set from client"
	halt
gtm_eof
cd $SERV_SIDE
$GTM << gtm_eof
	write ^x,!
	halt
gtm_eof

$head -n 1 cmerr_0.log | $grep "pid" >& gtcm_pid.log
if ($status) then
	echo "TEST-E-CMERR pid could not be determined. It is not printed in cmerr_0.log."
	echo "TEST-E-CMERR So it will not be printed in gtcm_server.pid. There'll be problems shutting down due to this."
	echo "INVALID --PID could not be determined" >! gtcm_server.pid
	exit 1
else
	$head -n 1 cmerr_0.log | sed 's/].*//g' | $tst_awk '{print $NF}' >! gtcm_server.pid

set time_stamp = `date +%H_%M_%S`
$gtm_tst/com/GTCM_SERVER_STOP.csh $time_stamp >&! gtcm_stop.log
set stat = $status
if ($stat) echo "TEST-E-GTCMSTOP Error from GTCM_STOP.csh. Check gtcm_stop.logx on the servers"
$grep FORCEDHALT cmerr_0.log
mv cmerr_0.log cmerr_0.logx
echo "Check the databases on the GT.CM Servers..."
$gtm_tst/com/dbcheck_base.csh
cd $TEST_DIR
$gtm_tst/com/portno_release.csh
