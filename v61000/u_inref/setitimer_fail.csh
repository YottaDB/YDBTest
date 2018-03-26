#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

####################################################
# This test simulates, via a white-box logic, an   #
# error return from setitimer(), which is used to  #
# start a new system timer or cancel an existing   #
# one. We expect appropriate error messages to be  #
# printed in both the console and the syslog.      #
####################################################

# Set the white-box test that simulates an error return from setitimer().
setenv gtm_white_box_test_case_number 98

####################################################
# Case 1. A setitimer() failure from direct mode.  #
####################################################
echo "Case 1. Generate a SETITIMERFAILED error from direct mode."
$echoline

# Enable the white-box test.
setenv gtm_white_box_test_case_enable 1

# Save the start time (for syslog searching).
set time_before = `$gtm_dist/mumps -run timestampdh -1`
echo "$time_before" >&! time_before.out

# Try to issue a hang from direct mode, thus invoking the white-box test logic.
$gtm_dist/mumps -direct <<EOF >&! mumps-dir.out
write "PID = "_\$job,!
hang 0.1
quit
EOF

# Disable the white-box test for MUMPS utilities to work.
unsetenv gtm_white_box_test_case_enable

# Get the pid to do a better grep for the error message.
set pid = `$tst_awk '/PID = / {print $NF}' mumps-dir.out`

# Verify that a core was generated and rename it for success of the test.
ls core*
if (! $status) then
	mv core* case-1.core
	mv YDB_FATAL* case-1.ZSHOW_DMP
endif

# Make sure that an error was printed in the console.
$gtm_tst/com/check_error_exist.csh mumps-dir.out SETITIMERFAILED

# Finally, ensure that there was also a syslog message.
$gtm_tst/com/getoper.csh "$time_before" "" "mumps-dir-syslog-1.outx" "" SETITIMERFAILED
$grep SETITIMERFAILED mumps-dir-syslog-1.outx | $grep -w $pid

# Ensure different syslog times for two cases by sleeping a second.
sleep 1

echo

####################################################
# Case 2. A setitimer() failure from an M routine. #
####################################################
echo "Case 2. Generate a SETITIMERFAILED error from an M routine."
$echoline

# Enable the white-box test.
setenv gtm_white_box_test_case_enable 1

# Produce a simple M file for testing.
cat <<EOF >&! test.m
test
  write \$job,!
  hang 0.2
  quit
EOF

# Save the start time (for syslog searching).
set time_before = `date +"%b %e %H:%M:%S"`

# Invoke the M program with a hang, thus triggering the white-box test logic.
$gtm_dist/mumps -run test >&! mumps-run.out

# Get the pid to do a better grep for the error message.
@ pid = `$head -n 1 mumps-run.out`

# Verify that a core was generated and rename it for success of the test.
ls core*
if (! $status) then
	mv core* case-2.core
	mv YDB_FATAL* case-2.ZSHOW_DMP
endif

# Make sure that an error was printed in the console.
$gtm_tst/com/check_error_exist.csh mumps-run.out SETITIMERFAILED

# Finally, ensure that there was also a syslog message.
$gtm_tst/com/getoper.csh "$time_before" "" "mumps-run-syslog-2.outx" "" SETITIMERFAILED
$grep SETITIMERFAILED mumps-run-syslog-2.outx | $grep -w $pid

unsetenv gtm_white_box_test_case_enable
