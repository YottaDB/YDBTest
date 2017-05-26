#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set gtcm_pid = `$grep "GTCM_SERVER pid" $tst_working_dir/gtcm_server.log | $tst_awk '{print $4}'`

echo "Shutting down gtcm_server..."
echo "kill -15 $gtcm_pid"
kill -15 $gtcm_pid

set wait = 120

while( $wait )
	$gtm_tst/com/is_proc_alive.csh $gtcm_pid
	set is_proc_gone = $status
	# is_proc_alive returns 0 if it is alive and 1 if not alive
	if ($is_proc_gone) then
		break
	else
		echo "wait 5 seconds..."
		sleep 5
		@ wait = $wait - 5
	endif
end
if !($wait) then
	echo "TEST-E-GTCM_STOP error stopping gtcm_server"
endif

$gtm_tst/com/portno_release.csh
echo "Successfully stoped gtcm_server"
