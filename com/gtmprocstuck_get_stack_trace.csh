#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The env variable gtm_procstuckexec points to this script. The script obtains the stack trace for the blocking pid
# for various GT.M stuck messages.
# Usage and params: gtmprocstuck_get_stack_trace.csh message waiting_pid blockingpid count

set type = $1
set waiter = $2
set blocker = $3
set count = $4
set monitor = "COUNTER_${type}_${blocker}_${count}.out"
echo $waiter >>& $monitor
set log = "TRACE_${type}_${waiter}_${blocker}.outx"
set mail_needed = 0
if ($type =~ {SEMWT2LONG,ERR_SHUTDOWN,MUTEXLCKALERT}) then
	set mail_needed = 1
endif

# We have seen files created by this script in home directory. Exit if this is not test directory.
# Add debug information to analyze the issue
set short_host = $HOST:r:r:r
set curdir = $PWD
if ($curdir !~ "*$gtm_tst_out*") then
	echo "check $log for debug information" | mailx -s "$short_host :: gtmprocstuck_get_stack_trace.csh not in test dir"  $mailing_list
	setenv >>&! $log
	$ps    >>&! $log
	echo "Exiting since pwd is $curdir"	>>&! $log
	exit 1
endif

set curtime = `date +%H:%M:%S`
set border =  "###############################################################################"
echo $border 							>>&! $log
echo "BLOCKING PID = $blocker"					>>&! $log
echo "WAITING PID = $waiter"					>>&! $log
echo "Time before calling dbx: "`date`				>>&! $log
if ( "" != $count ) echo "Count is: "$count			>>&! $log
echo $border							>>&! $log
set psfile = psinfo_$waiter.txt
set image = `$gtm_tst/com/determine_exe_name.csh $blocker $psfile`
if ($image == "") echo "TEST-I-UNDETERMINED_EXE, Could not determine the executable for $blocker" 	>>&! $log
# There have been instances where dbx gets hung infinitely. So push the invocation in the background
# if get_dbx_c_stack_trace script is running beyond 600 seconds, kill it and the hung dbx and retry
set retry = 2
while ($retry > 0)
	set pidfilename = get_dbx_${type}_${waiter}_${blocker}_${retry}_$$.pid
	($gtm_tst/com/get_dbx_c_stack_trace.csh $blocker $image & ; echo $! > $pidfilename)		>>&! $log
	set dbx_parent_pid = `cat $pidfilename`
	if (""  == "$dbx_parent_pid") then
		# This is to make the test fail, allowing us to debug and figure out why the pid is null
		# Once that is figured out, this block can be removed
		echo "TEST-E-NULLPID Unable to get pid of get_dbx_c_stack_trace.csh"	>>&! ${pidfilename}.null.out
	endif
	echo "pid of get_dbx_c_stack_trace.csh : $dbx_parent_pid"					>>&! $log
	$gtm_tst/com/wait_for_proc_to_die.csh "$dbx_parent_pid" 600 . nolog				>>&! $log
	if ($status) then
		echo "get_dbx_c_stack_trace.csh with pid $dbx_parent_pid is still running"		>>&! $log
		set dbx_pid = `$ps |& $tst_awk '{ if ($3 == "'$dbx_parent_pid'") {print $2 ; exit}}'`
		echo "kill $dbx_pid $dbx_parent_pid and retry get_dbx_c_stack_trace"			>>&! $log
		$kill9 $dbx_pid $dbx_parent_pid
		@ retry = $retry - 1
		set dbx_status = 1
	else
		set retry = 0
		set dbx_status = 0
	endif
end
$gtm_tst/com/check_PC_INVAL_err.csh $blocker $log
echo $border							>>&! $log
echo "Now the time is: "`date`" dbx exit status: "$dbx_status	>>&! $log
set cnt = `cat $monitor | wc -l`
if ($type == "JNLPROCSTUCK" && ($?gtm_test_freeze_on_error)) then
	if (1 == $gtm_test_freeze_on_error) then
	    echo "Unfreezing to avoid instance freeze hang" >>&! $log
	    $MUPIP replicate -source -freeze=off >>&! $log
	endif
endif
# Send mail once in 10 times and send only 5 mails
if ( !($cnt % 10 ) && ($cnt <= 50) )  then
		($tail -n 100 $log) | mailx -s "$short_host : Time: $curtime; $type - No progress Check at $curdir" $mailing_list
endif
if ( ($mail_needed) && ($?gtm_procstuck_mail) ) then
	if ($type == "ERR_SHUTDOWN") then
		($tail -n 100 $log) | mailx -s "$short_host : Time: $curtime; Source server $blocker taking too long to shutdown. Check at $curdir" $mailing_list
	else if (($type == "SEMWT2LONG_FTOK") || ($type == "SEMWT2LONG_ACCSEM")) then
		($tail -n 100 $log) | mailx -s "$short_host : Time: $curtime; $type - $blocker holding the semaphore. Check at $curdir" $mailing_list
	else if ($type == "MUTEXLCKALERT") then
		($tail -n 100 $log) | mailx -s "$short_host : Time: $curtime; $type - $blocker holding crit. Check at $curdir" $mailing_list
	endif
endif
exit $dbx_status
