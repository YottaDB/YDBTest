#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Usage : get_rcvr_stack_trace.csh [logfile_prefix]
#   The optional logfile_prefix would be used as the file name prefix for various logs
set logbase = "get_rcvr_stack_trace"
if ("" != "$1") set logbase = "$1_$logbase"

set rcvckhlth = "${logbase:r}_rc.out"
set stacktracercv = "${logbase:r}_rcv.out"
set stacktraceupd = "${logbase:r}_upd.out"

# First check if receiver server and update process is alive
$MUPIP replicate -receiver -checkhealth >&! $rcvckhlth

if ( 2 != `$grep -c "is alive" $rcvckhlth` ) then
	# Receiver or update process is not alive
	echo "STACKTRACE-E-NOTALIVE Receiver/Update process is not alive"
	cat $rcvckhlth
	exit 1
endif

set pidrcv = `$tst_awk '/Receiver server is alive/ {print $2}' $rcvckhlth`
set pidupd = `$tst_awk '/Update process is alive/ {print $2}' $rcvckhlth`
if ( ("" == "$pidrcv") || ("" == "$pidupd") ) then
	echo "STACKTRACE-E-PID unable to obtain pid of receiver or update process"
	cat $rcvckhlth
	exit 1
endif

$gtm_tst/com/get_dbx_c_stack_trace.csh $pidrcv $gtm_exe/mupip	>>&! $stacktracercv
$gtm_tst/com/get_dbx_c_stack_trace.csh $pidupd $gtm_exe/mupip	>>&! $stacktraceupd
