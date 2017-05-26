#!/usr/local/bin/tcsh -f

# This script signals all the background do_dbx_c_stack_trace.csh jobs to die right away.
# The do_dbx_c_stack_trace.csh process poll for the file STOP_dbx_c_stack_trace.txt every second
# On seeing the above file, the jobs exit after printing the pid it was tracing in the file: dbx_c_stack_trace.done

touch STOP_dbx_c_stack_trace.txt
set max_wait = 120
set fromtime = `date`
while (0 < $max_wait)
	if (-e dbx_c_stack_trace.trace) then
		break
	endif
	sleep 1
	@ max_wait = $max_wait - 1
end
set totime = `date`
if (0 == $max_wait) then
	echo "DBX-E-TRACE-NOT-STARTED The trace has still not starte.Waited from : $fromtime to $totime"
endif
set no_of_jobs = `wc -l dbx_c_stack_trace.trace | $tst_awk '{print $1}'`
set max_wait = 120
while ( 0 < $max_wait)
	if (`wc -l dbx_c_stack_trace.done | $tst_awk '{print $1}'` == $no_of_jobs) then
		# In case there are multiple times we are called in the test, save the time of this call and
		# remove STOP_dbx_c_stack_trace.txt so there will be no premature exits of do_dbx_c_stack_trace
		# in a subsequent run.
		ls -l STOP_dbx_c_stack_trace.txt >>& dbx_c_stack_trace_stop.out
		ls -l --full STOP_dbx_c_stack_trace.txt >>& dbx_c_stack_trace_stop.out
		echo "no_of_jobs: $no_of_jobs" >>& dbx_c_stack_trace_stop.out
		echo "dbx_c_stack_trace.done" >>& dbx_c_stack_trace_stop.out
		cat dbx_c_stack_trace.done >>& dbx_c_stack_trace_stop.out
		echo "dbx_c_stack_trace.trace" >>& dbx_c_stack_trace_stop.out
		cat dbx_c_stack_trace.trace >>& dbx_c_stack_trace_stop.out
		\rm STOP_dbx_c_stack_trace.txt
		exit
	endif
	sleep 1
	@ max_wait = $max_wait - 1
end

echo "TEST-E-BKGROUND Not all background jobs exited.. Check dbx_c_stack_trace.trace and dbx_c_stack_trace.done"
# If the control is here, it means not all background jobs exited
# It is not necessary to give a -E- message here.
# If background jobs are not handled properly, the test anyways will fail
# But if the background jobs are handled properly, this is a false alarm.
