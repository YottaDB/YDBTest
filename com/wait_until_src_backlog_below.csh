#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2004, 2014 Fidelity Information Services, Inc	#
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
#
# Waits (in increments of 1 second) until the current backlog is <= the input backlog.
#
# $1 - backlog limit to wait for
# $2 - optional max. wait time (by default it is 1800 seconds, i.e. 30 minutes)
# $3 - optional log file name
# $4 - optional noerror - Silently exit even if backlog did not decrease after the max wait
#
# Exits with normal status   i.e. 0 if current backlog <= P1 within timeout period
# Exits with abnormal status i.e. 1 if current backlog >  P1 even after timeout period
#
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
	set logfile = "wait_src_backlog_$$_`date +%H%M%S`.out"
else
	set logfile = "$3"
endif

if ("noerror" == "$4") set noerror=1

set vernow = "$gtm_exe:h:t"
if (`expr $vernow \< "V51000"`) then
	setenv gtm_test_instsecondary
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
set sleepinterval = 1
set nowtime = `date +%s`
@ timeout = $nowtime + $maxwait
set sblogfile = "${logfile:r}_sb.out"
set srcckhlth = "${logfile:r}_sc.out"
set stacktrace = "${logfile:r}_stacktrace.out"

# First check if the replication source server is alive and in active mode
$MUPIP replicate -source $gtm_test_instsecondary -checkhealth >&! $srcckhlth

if ( 0 != `$grep -c 'alive in PASSIVE mode' $srcckhlth` ) then
	echo "SRCBACKLOG-E-PASSIVE Source server is in PASSIVE mode"	>>&! $logfile
	cat $srcckhlth							>>&! $logfile
	exit 1
endif

set pidsrc = `$tst_awk '/Source server is alive in ACTIVE mode/ { print $2}' $srcckhlth`
if ( "" == "$pidsrc" ) then
	echo "SRCBACKLOG-E-PID unable to obtain pid of source server"	>>&! $logfile
	cat $srcckhlth							>>&! $logfile
	exit 1
endif

while ($nowtime < $timeout)
	$MUPIP replic -source $gtm_test_instsecondary -showbacklog >& $sblogfile
	set backlog = `$tst_awk '/backlog number of transactions/ {print $1}' $sblogfile`
	if ("" == "$backlog") then
		echo "SRCBACKLOG-E-FAILED -showbacklog failed. Check $sblogfile" >>&! $logfile
		cat $sblogfile							>>&! $logfile
		exit 1
	endif
	cat $sblogfile >>&! ${logfile:r}_trace.out
	if ($backlog <= $limit) break
	sleep $sleepinterval
	set nowtime = `date +%s`
end

cat $sblogfile  >>&! $logfile
if ($nowtime < $timeout) then
	exit 0
else
	$gtm_tst/com/get_dbx_c_stack_trace.csh $pidsrc $gtm_exe/mupip	>>&! $stacktrace
	# If noerror is set, just silently exit
	if ($?noerror) exit 0
	echo "SRCBACKLOG-E-TIMEOUT did not go below $limit in $maxwait seconds. Current backlog: $backlog"	 >>&! $logfile
	exit 1
endif
