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

####################################################################################################################################
# This test verifies that the changes made as a part of GTM-7279 (deferring interrupts for most of wcs_wtstart()) do not have some #
# obvious side effects. Depending on a randomly chosen number we activate one of the seven white-box code snippets inside          #
# wcs_wtstart() to print a notification message and start an infinite sleep. Note that the white-box activation also happens upon  #
# a particular number of wcs_wtstart() invocations. We ensure that while sleeping (inside an interrupt-deferred zone), the process #
# successfully defers two SIGTERM signals, but terminates on the third one, without causing any adverse effects to itself or its   #
# successors.                                                                                                                      #
####################################################################################################################################

# Create a database with significantly big records for faster block filling.
$gtm_tst/com/dbcreate.csh mumps 1 256 4096

# Prepare a white-box test environment to activate a sleep in one of the predetermined places
# inside wcs_wtstart.c based on the randomly selected gtm_white_box_test_case_count variable.
setenv gtm_white_box_test_case_number 97
setenv gtm_white_box_test_case_enable 1
if (! $?gtm_test_replay) then
	setenv wcs_wtstart_position `$gtm_dist/mumps -run %XCMD 'write 1+$random(7)'`
	# Certain placements of the white-box-test code are not accessible in MM, so regenerate.
	while (("MM" == $acc_meth) && ((3 == $wcs_wtstart_position) || (4 == $wcs_wtstart_position)))
		setenv wcs_wtstart_position `$gtm_dist/mumps -run %XCMD 'write 1+$random(7)'`
	end
	# To avoid extending test runtimes too much, limit the required number of wcs_wtstart()
	# invocations to 40.
	setenv wcs_wtstart_iteration `$gtm_dist/mumps -run %XCMD 'write 1+$random(40)'`
	@ count = (100 * $wcs_wtstart_iteration) + $wcs_wtstart_position
	setenv gtm_white_box_test_case_count $count
	echo "setenv gtm_white_box_test_case_count $gtm_white_box_test_case_count" >> settings.csh
endif

# There will be five processes, of which one is a white-box-test process and one is a writer.
@ num_of_processes = 5
@ num_of_writers = 1

# Launch the white-box process in the background.
($gtm_dist/mumps -run wbox^updates $num_of_processes >&! mumps-wb.out &) > /dev/null

# Disable the white-box test.
unsetenv gtm_white_box_test_case_enable

# Since we do not want to look for the pid in the log immediately upon creation (as the pid
# might not have been printed), only do so upon encountering the message that should follow.
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps-wb.out -duration 60 -message "started"

# Obtain the PID of the white-box process.
@ pid = `$head -n 1 mumps-wb.out`

# Launch all writer processes, ensuring that the white-box environment is present (to avoid
# failing asserts), but the count is zero, thus bypassing any white-box logic.
@ process_count = 1
setenv gtm_white_box_test_case_count 0
setenv gtm_white_box_test_case_enable 1
while ($process_count <= $num_of_writers)
	($gtm_dist/mumps -run writer^updates $process_count $pid >&! mumps${process_count}.out &) > /dev/null
	@ process_count = $process_count + 1
end
setenv gtm_white_box_test_case_enable 0

# Launch all reader processes.
while ($process_count < $num_of_processes)
	($gtm_dist/mumps -run reader^updates $process_count $pid >&! mumps${process_count}.out &) > /dev/null
	@ process_count = $process_count + 1
end

# Wait for all processes to start.
@ process_count = 1
while ($process_count < $num_of_processes)
	$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps${process_count}.out -duration 60 -message "started"
	@ process_count = $process_count + 1
end

# Once the white-box test logic has been reached, we can start the actual testing.
$gtm_tst/com/wait_for_log.csh -log mumps-wb.out -duration 90 -message "WCS_WTSTART: STARTING SLEEP"
if ($status) then
	exit 1
endif

# We expect the process to stay alive after the first SIGTERM signal, but we do verify that the exit_state
# global has been incremented.
kill -15 $pid
$gtm_tst/com/wait_for_log.csh -log mumps-wb.out -duration 60 -message "exit_state is 1"

# Analogously, the second SIGTERM should not kill the process, but the exit_state global should be bumped up.
kill -15 $pid
$gtm_tst/com/wait_for_log.csh -log mumps-wb.out -duration 60 -message "exit_state is 2"

# The third SIGTERM should be terminal, so expect the process to shut down.
kill -15 $pid
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300

# Wait for all writers to die.
@ process_count = 1
while ($process_count <= $num_of_writers)
	@ pid = `$head -n 1 mumps${process_count}.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 420
	@ process_count = $process_count + 1
end

# Wait for all readers to die.
while ($process_count < $num_of_processes)
	@ pid = `$head -n 1 mumps${process_count}.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 210
	@ process_count = $process_count + 1
end

# To avoid failures, extract the expected FORCEDHALT messages out of the log file.
$gtm_tst/com/check_error_exist.csh mumps-wb.out FORCEDHALT

# Verify that the database is OK.
$gtm_tst/com/dbcheck.csh
