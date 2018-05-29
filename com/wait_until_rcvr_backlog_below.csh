#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


set limit=$1
if ( $limit < 0) then
	echo "BACKLOG-E-NEGATIVE limit cannot be a negative number"
	exit 1
endif

if ($2 == "") then
	set maxwait=1800
else
	set maxwait=$2
endif

if ("" == $3) then
	set logfile = "wait_rcvr_backlog_$$_`date +%H%M%S`.out"
else
	set logfile = "$3"
endif

if ("noerror" == "$4") set noerror=1

set sleepinterval = 1
set nowtime = `date +%s`
@ timeout = $nowtime + $maxwait
set sblogfile = "${logfile:r}_sb.out"
set rcvckhlth = "${logfile:r}_rc.out"
set stacktracercv = "${logfile:r}_stacktrace_rcv.out"
set stacktraceupd = "${logfile:r}_stacktrace_upd.out"

# First check if receiver server and update process is alive
$MUPIP replicate -receiver -checkhealth >&! $rcvckhlth

if ( 2 != `$grep -c "is alive" $rcvckhlth` ) then
	# Receiver or update process is not alive
	echo "RCVR_BACKLOG-E-NOTALIVE Receiver/Update process is not alive"	 >&! $logfile
	cat $rcvckhlth								>>&! $logfile
	exit 1
endif

set pidrcv = `$tst_awk '/Receiver server is alive/ {print $2}' $rcvckhlth`
set pidupd = `$tst_awk '/Update process is alive/ {print $2}' $rcvckhlth`
if ( ("" == "$pidrcv") || ("" == "$pidupd") ) then
	echo "RCVR_BACKLOG-E-FAIL Cannot obtain pid of receiver or update process"	 >&! $logfile
	cat $rcvckhlth									>>&! $logfile
	exit 1
endif

while ($nowtime < $timeout)
	echo "---------------------------------------------------------------"	>>&! ${logfile:r}_trace.out
	echo "Current Time is : `date`"						>>&! ${logfile:r}_trace.out
	echo "---------------------------------------------------------------"	>>&! ${logfile:r}_trace.out
	$MUPIP replic -receiv -showbacklog >& $sblogfile
	set backlog = `$tst_awk '/backlog/ {print $1}' $sblogfile`
	if ("" == "$backlog") then
		echo "RCVR_BACKLOG-E-FAILED -showbacklog failed. Check $sblogfile"	 >&! $logfile
		cat $sblogfile								>>&! $logfile
		exit 1
	endif
	cat $sblogfile >>&! ${logfile:r}_trace.out
	if ($backlog <= $limit) break
	sleep $sleepinterval
	set nowtime = `date +%s`
end

cat $sblogfile  >&! $logfile
if ($nowtime < $timeout) then
	exit 0
else
	$gtm_tst/com/get_dbx_c_stack_trace.csh $pidrcv $gtm_exe/mupip	>>&! $stacktracercv
	$gtm_tst/com/get_dbx_c_stack_trace.csh $pidupd $gtm_exe/mupip	>>&! $stacktraceupd
	# If noerror is set, just silently exit
	if ($?noerror) exit 0
	echo "RCVR_BACKLOG-E-TIMEOUT did not go below $limit in $maxwait seconds. Current backlog: $backlog"	>&! $logfile
	exit 1
endif
