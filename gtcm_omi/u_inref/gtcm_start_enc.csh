#!/usr/local/bin/tcsh  -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set portno = `$gtm_tst/com/portno_acquire.csh`
echo "Starting the gtcm_server with port number $portno..."
$gtm_tst/com/is_port_in_use.csh $portno 
if( 0 == $status ) then
	echo "TEST-E-GTCM_SERVER: gtcm_server cannot start. Port # $portno is in use"
	exit 1
endif
echo $portno > $tst_working_dir/portno.txt
setenv save_gtm_passwd $gtm_passwd
unsetenv gtm_passwd
$gtm_dist/gtcm_server -service $portno -log $tst_working_dir/gtcm_server.log -multiple -hist&
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/wait_for_log.csh -log $tst_working_dir/gtcm_server.log -message "GTCM_SERVER pid :" -duration 30 -waitcreation
if ($status) then
	echo "TEST-E-GTCM_SERVER: Failed to start gtcm_server"
	echo "ps output at this stage" #BYPASSOK
	$ps
	exit 1
endif
set gtcm_pid = `$grep "GTCM_SERVER pid" $tst_working_dir/gtcm_server.log | $tst_awk '{print $4}'`
# have a small lop that runs for 5 seconds max to ensure the gtcm service has started. Sometime it might take little
# extra seconds to start in which case the test should not report bogus error.
set wait = 5
while( $wait )
	# is_proc_alive returns 0 if it is alive and 1 if not alive
	$gtm_tst/com/is_proc_alive.csh $gtcm_pid
	if ($status) then
		echo "wait 1 second..."
		sleep 1
		@ wait = $wait - 1
	else
		break
	endif
end

if !($wait) then
	echo "TEST-E-GTCM_SERVER: Failed to start gtcm_server"
	echo "ps output at this stage" #BYPASSOK
	$ps
	exit 1
endif
