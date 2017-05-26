#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# used by gtm6571 as procstuckexec action
	set trace = "invoke_trace.$2"
	echo $gtm_tst/com/gtmprocstuck_get_stack_trace.csh $1 $2 $3 $4	>>&! $trace
	$gtm_tst/com/gtmprocstuck_get_stack_trace.csh $1 $2 $3 $4
	if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
		$grep "has been disabled" TRACE_$1_$2_$3.outx		>>&! $trace
		set stat1 = $status
	else if ("$HOSTOS" == "OSF1") then
		$grep stop TRACE_$1_$2_$3.outx				>>&! $trace
		set stat1 = $status
	else
		$grep tach TRACE_$1_$2_$3.outx | $grep $3		>>&! $trace
		set stat1 = $status
	endif
	echo $stat1							>>&! $trace
	if ( 0 == $stat1 ) \rm mutexlckalert_?
	$grep -s foo mutexlckalert_?					>>&! $trace
	exit ( $stat1 )
