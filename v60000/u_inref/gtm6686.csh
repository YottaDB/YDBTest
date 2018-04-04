#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2014 Fidelity Information Services, Inc	#
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

####################################################################################
# This test verifies that under-construction util_out buffers are protected        #
# against corruption on timer pops.                                                #
####################################################################################

$gtm_tst/com/dbcreate.csh .

# activate the white-box timer to frequently write to syslog
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 61
setenv gtm_white_box_test_case_count 0

# start printing error messages and interrupting them with timer pops
( $gtm_dist/mumps -run gtm6686 & ) >&! gtm6686.outx

# unset the white-box test variables for other processes
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

# wait for the process to save its pid in a file
$gtm_tst/com/wait_for_log.csh -log pid.outx

# remember the pid
set pid = `cat pid.outx`

# give the process 10 seconds to run
$gtm_dist/mumps -direct <<EOF
hang 10
set ^quit=1
halt
EOF

# wait fo the backgrounded process to die
$gtm_tst/com/wait_for_proc_to_die.csh $pid -1

# get the number of iterations that the main loop went through
set loop_iterations = `cat iterations.outx`

# get the number of expected complete error messages printed
set message_count = `$grep 'YDB-I-SETEXTRENV, Database files are missing or Instance is frozen; supply the database files, wait for the freeze to lift or define gtm_extract_nocol to extract possibly incorrect collation' gtm6686.outx | wc -l`

# compare the numbers and signal an error if they do not match
if ($loop_iterations != $message_count) then
	echo "TEST-E-FAIL: Expected the error message in full $loop_iterations times, but only saw $message_count. For details please check iterations.outx."
endif

$gtm_tst/com/dbcheck.csh
