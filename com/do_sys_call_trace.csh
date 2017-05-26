#!/usr/local/bin/tcsh -f
#
# Waits for pid to be available before calling the tracing tool
#
# $1 - pid to get stack trace of
# $2 - max time to wait for the process to be available - optional - defaults to 120 seconds
set pid = $1
set max_wait = 120
if ($1 == "") then
	echo "TEST-E-NOPID No pid provided"
	exit 1
endif
if ($2 != "") set max_wait = $2
set log = "sys_call_trace_${pid}_`date +%H%M%S`.outx"
set donefile = "sys_call_trace_${pid}.done"
set stopfile = "sys_call_trace_${pid}.stop"
$gtm_tst/com/is_proc_alive.csh $pid
set is_proc_alive = $status
if (($is_proc_alive) && ( "-1" == "$max_wait")) then
        echo "TEST-I-WAIT. $pid is not found. Since wait time is $max_wait , not waiting.... " >>&! $log
        echo "Not found : $pid - truss tracing will exit now" >>&! $donefile
        exit 0
endif

set border =  "###############################################################################"
echo $border > $log
echo "Tracing $pid using $truss" 
set wait = $max_wait
# is_proc_alive returns 0 if the process is alive , 1 if not alive
while (($is_proc_alive) && ($wait))
	if (-e $stopfile) then
		echo "Stopped : $pid - truss tracing will exit now" >>&! $donefile
		exit 0
	endif
        @ wait = $wait - 1
        sleep 1
        $gtm_tst/com/is_proc_alive.csh $pid
        set is_proc_alive = $status
end
if !($wait) then
        echo "TEST-E-WAIT. $pid not found even after waiting $max_wait seconds" >>&! $log
        $ps >>&! $log
        echo "Error - Not found : $pid - truss tracing will exit now" >>&! $donefile
        exit 1
endif
echo "$truss -o $log -p $pid"
$truss -o $log -p $pid
echo "Done : $pid - truss tracing will exit now" >>&! $donefile 
exit
