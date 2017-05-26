#!/usr/local/bin/tcsh  -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Usage: GTCM_SERVER.csh <portno> <start_time>
#
if (("" == "$1") || ("" == $2)) then
	echo "Needs portno and time stamp!"
	exit 1
else
	set portno = "$1"
	set time_stamp = "$2"
endif
echo portno is $portno
echo time is $time_stamp
# Just to make sure it is still free
$netstat |& $grep $portno

# To reduce calls to name resolution and in turn avoiding the possiblity of a hang
# we disable trace option from gtcm_gnp temporarily

#if ($tst_gtcm_trace) then
#	set trace_opt="-trace"
#else
#	set trace_opt=""
#endif
echo $gtm_dist/gtcm_gnp_server -service=$portno -log=cmerr_${time_stamp}.log
$gtm_dist/gtcm_gnp_server -service=$portno -log=cmerr_${time_stamp}.log < /dev/null
set stat = $status

if ($stat) then
	echo "TST-E-GTCMSERVER Error starting GT.CM server. Check cmerr_${time_stamp}.log on log $HOST"
	exit $stat
endif

set wait_time = 60			# Wait for a maximum of 60 seconds
set sleeptime = 1			# Start with 1 sec sleep between attempts
echo "Will wait for $wait_time seconds for the server to come up..."
set now_time = `date +%s`
@ max_wait = $now_time + $wait_time
while ($now_time <= $max_wait)
	$gtm_tst/com/is_port_in_use.csh $portno
	if !($status) then
		echo "Yes, I got it..."
		echo ""
		break
	endif
	sleep $sleeptime
	set now_time = `date +%s`
	@ sleeptime = $sleeptime + 1	# Increase the sleep duration between attempts
	echo "wait one more round..."
end
if ($now_time > $max_wait) then
	$gtm_tst/com/is_port_in_use.csh $portno
	if  ($status) then
		echo "TST-E-GTCMSERVER Error starting GT.CM server. Check cmerr_${time_stamp}.log on log $HOST. It did not start within $wait_time secs."
		exit 1
	endif
endif

if (-e gtcm_server.pid) mv gtcm_server.pid gtcm_server.pid_`date +%H_%M_%S`

$head -n 1 cmerr_${time_stamp}.log | $grep "pid"
if ($status) then
	echo "TEST-E-CMERR pid could not be determined. It is not printed in cmerr_${time_stamp}.log."
	echo "TEST-E-CMERR So it will not be printed in gtcm_server.pid. There'll be problems shutting down due to this."
	echo "INVALID --PID could not be determined" >! gtcm_server.pid
	exit 1
else
	$head -n 1 cmerr_${time_stamp}.log | sed 's/].*//g' | $tst_awk '{print $NF}' >! gtcm_server.pid
endif

