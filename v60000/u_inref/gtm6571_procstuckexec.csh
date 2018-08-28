#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
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
# used by gtm6571 as procstuckexec action
	set trace = "invoke_trace.$2"
	echo $gtm_tst/com/gtmprocstuck_get_stack_trace.csh $1 $2 $3 $4	>>&! $trace
	$gtm_tst/com/gtmprocstuck_get_stack_trace.csh $1 $2 $3 $4
	$grep tach TRACE_$1_$2_$3.outx | $grep $3		>>&! $trace
	set stat1 = $status
	echo "gtmprocstuck_get_stack_trace.csh $1 $2 $3 $4 : Exit status is $stat1"	>>&! $trace
	set file = mutexlckalert_?
	\mv $file ${file}_$2
	exit ( $stat1 )
