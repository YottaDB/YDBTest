#!/usr/local/bin/tcsh -f

# Waits till the pid is available (with a timeout).
# As soon as the pid is available,calls get_dbx_c_stack_trace.csh to get a C-stack trace of the process
# This is done as long as the pid is available
#
# $1 - pid to get stack trace of
# $2 - executable (gtm or mupip or dse etc.) that pid is running
# $3 - max time to wait for the process to be available - optional - defaults to 120 seconds
# $4 - sleep interval between dbx attempts - optional - defaults to 1
#
# The following option may appear anywhere in the command line, shifting the above positional
# arguments accordingly, if needed.
#
# -instance=id - add id to filenames, allowing multiple instances in the same directory - optional
#
set args=()
set instance=""

while ($#)
	if ("$1" =~ "-instance=*") then
		set instance="_${1:s/-instance=//}"
	else
		set args=(${args:q} "$1")
	endif
	shift
end

set donefile="dbx_c_stack_trace${instance}.done"
set stopfile="STOP_dbx_c_stack_trace${instance}.txt"

set pid = $args[1]
set image = $args[2]
set max_wait = 120
set sleep_interval = 1
if ($#args >= 3 ) then
	set max_wait = $args[3]
endif
if ($#args >= 4 ) then
	set sleep_interval = $args[4]
endif
set log = "stack_trace_${pid}_`date +%H%M%S`.out"
touch "$donefile"
$gtm_tst/com/is_proc_alive.csh $pid
set is_proc_alive = $status

if (($is_proc_alive) && ( "-1" == "$max_wait")) then
	echo "TEST-I-WAIT. $pid is not found. Since wait time is $max_wait , not waiting.... " >>&! $log
	echo "Not found : $pid - dbx tracing will exit now" >>&! "$donefile"
	exit 0
endif

set border =  "###############################################################################"
set wait = $max_wait
echo $border > $log
echo "Tracing $pid using image $image and $dbx"  >>&! $log

# is_proc_alive returns 0 if the process is alive , 1 if not alive
while (($is_proc_alive) && ($wait))
	@ wait = $wait - 1
	sleep 1
	$gtm_tst/com/is_proc_alive.csh $pid
	set is_proc_alive = $status
end

if !($wait) then
	echo "TEST-E-WAIT. $pid not found even after waiting $max_wait seconds" >>&! $log
	$ps >>&! $log
	echo "Error - Not found : $pid - dbx tracing will exit now" >>&! "$donefile"
	exit 1
endif

# is_proc_alive returns 0 if the process is alive , 1 if not alive
while !($is_proc_alive)
	set total_sleep = 1
	while ($total_sleep < $sleep_interval)
		@ total_sleep = $total_sleep + 1
		sleep 1
		if (-e "$stopfile") then
			echo "Stopped : $pid - dbx tracing will exit now" >>&! "$donefile"
			exit
		endif
	end
	$gtm_tst/com/is_proc_alive.csh $pid
	set is_proc_alive = $status
	if !($is_proc_alive) then
		echo $border  						>>&! $log
		echo "Time before calling dbx: "`date`			>>&! $log
		echo $border 						>>&! $log
		$gtm_tst/com/get_dbx_c_stack_trace.csh $pid $image 	>>&! $log
		$gtm_tst/com/check_PC_INVAL_err.csh $pid $log
		echo "Now the time is: "`date`			>>&! $log
	endif
end
echo "Exited : $pid - dbx tracing will exit now" >>&! "$donefile"
