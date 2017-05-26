#!/usr/local/bin/tcsh -f
# Usage is to wait for the backup process to be spawned 
# And then trace all the processes attached to the database, including the backup process
set max_wait = 60
set sleep_interval = 1
set found_backup=1
set fromtime = `date`
while (($found_backup != 0) && ($max_wait))
	@ max_wait = $max_wait - 1
	$psuser | $grep "$gtm_exe/mupip backup -i -dbg -o -t=1 DEFAULT online2.inc" | $grep -v grep >& psinfo.txt
	set found_backup = $status
	if ($found_backup) sleep $sleep_interval
end
set totime = `date`
if !($max_wait) then
	echo "TEST-E-WAIT Could not find the backup process"
	echo "Waited from $fromtime to $totime"
else
	echo "Found the backup process and tracking it"
	echo `date`
	$gtm_tst/com/get_stack_trace_allusers.csh >& stacktrace.outx
endif
