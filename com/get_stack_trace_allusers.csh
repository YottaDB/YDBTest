#!/usr/local/bin/tcsh -f
#
# Gets a list of processes accessing the database and calls do_dbx_c_stack_trace.csh for each of the PIDs
# usage :  $gtm_tst/com/get_stack_trace_allusers.csh [sleep_interval] >&! log.outx
# $1 - The sleep interval between dbx attempts - defaults to 30.
# This is passed as a parameter to do_dbx_c_stack_trace.csh
# Note that there is a ps output and so it is safe to redirect the output to a logx file
# If sys_call_trace is set, do_sys_call_trace.csh will be called for the passive source process, instead of do_dbx_c_stack_trace.csh
#
if ("" != "$1") then
	set sleep_interval = $1
else
	set sleep_interval = 30
endif
set echoline = 'echo ###################################################################'
$echoline
date
$echoline
# Let's not worry about the location now. If it is primary, the receiv will not give a PID (though the command will error out)
# PID for source server
set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`
echo "PID for source server : $pidsrc"

# PID for receiver server
set pidrecv=`$MUPIP replicate -receiv -checkhealth |& $grep PID | $grep Receiver | $tst_awk '{printf(" %s", $2);}'`
echo "PID for receiver server : $pidrecv"

# PID for update process
set pidupd=`$MUPIP replicate -receiv -checkhealth |& $grep PID | $grep Update | $tst_awk '{printf(" %s", $2);}'`
echo "PID for update process : $pidupd"

# All the other processes accessing the database
$fuser *.dat
set allps = `$fuser *.dat | $tst_awk '{print $2}'`
echo "All the other processes accessing the database $allps"

set pidall = "$pidrecv $allps $pidupd"
# Do not trace the passive server process if doing a sys call trace
if ($?sys_call_trace == 0) set pidall = "$pidall $pidsrc"
# The pidall string might have pids that are repeating (e.g, allps and pidsrc are same). Get unique pids
set pidtrace = `echo $pidall | $tst_awk '{for(x=1;x<=NF;x++) array[$x]++ ; for (pid in array) print pid}'`
if (($?sys_call_trace != 0) && ("" != $pidrecv)) set pidtrace = `echo $pidtrace | sed 's/'$pidsrc'//'`
echo "The processes that will be traced using do_dbx_c_stack_trace.csh : $pidtrace"

$echoline
$ps
$echoline

foreach pid ($pidtrace)
	$gtm_tst/com/do_dbx_c_stack_trace.csh $pid $gtm_exe/mupip -1 $sleep_interval &
	echo "tracing $pid" >>&! dbx_c_stack_trace.trace
end

#Trace only the receiver's source process
if (($?sys_call_trace != 0) && ("" != $pidupd)) then
	echo "The process that will be traced using do_sys_call_trace.csh : $pidsrc"
	$gtm_tst/com/do_sys_call_trace.csh $pidsrc &
endif

