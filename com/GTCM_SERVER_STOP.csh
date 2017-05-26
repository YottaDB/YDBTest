#!/usr/local/bin/tcsh -f
#
# STOP the GT.CM SERVER

if ("" == "$1") then
	echo "Needs time stamp!"
	exit
endif
set time_stamp = $1

set pid = `cat gtcm_server.pid`
#set log_file = gtcm_stop_${time_stamp}.log
echo "GT.CM Server that will be stopped: $pid"  
echo ""
echo "All gtcm processes:"  
$ps | $grep "$gtm_exe/gtcm_"
# in order not to kill other GT.CM servers, pick up the pid from a log file
echo ""
echo "Is $pid still running?:" 
$ps | $grep -w $pid
$gtm_tst/com/is_proc_alive.csh $pid
if ($status) then
	# is_proc_alive.csh exits with status 1 if the process is not alive
	echo "TEST-E-GTCMSERVERSTOP GTCM Server is not there! Cannot kill! Server $HOST"
	exit 1
endif

echo ""
echo "Kill GT.CM Server... " 
date
echo "kill -15 $pid"
kill -15  $pid 
echo ""
echo "Afterwards, is $pid still running?..." 
date
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
set stop_stat = $status
if (0 != $stop_stat) then
	echo "%TEST-E-GTCMSERVERSTOP GT.CM Server did not die!"
	date
	$ps | $tst_awk '$2 == "'$pid'" {print}'
	exit 1
endif
