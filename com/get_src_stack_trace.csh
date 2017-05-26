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
set logbase = "get_src_stack_trace"
if ("" != "$1") set logbase = "$1_$logbase"


set vernow = "$gtm_exe:h:t"
if (`expr $vernow \< "V51000"`) then
	setenv gtm_test_instsecondary
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
set srcckhlth = "${logbase:r}_sc.out"
set stacktrace = "${logbase:r}_stacktrace.out"

$MUPIP replicate -source $gtm_test_instsecondary -checkhealth >&! $srcckhlth

set pidsrc = `$tst_awk '/Source server is alive/ { print $2}' $srcckhlth`
if ( "" == "$pidsrc" ) then
	echo "STACKTRACE-E-PID unable to obtain pid of source server"
	cat $srcckhlth
	exit 1
endif

$gtm_tst/com/get_dbx_c_stack_trace.csh $pidsrc $gtm_exe/mupip	>>&! $stacktrace
