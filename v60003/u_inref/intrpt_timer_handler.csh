#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

####################################################################################################
# This test verifies that a GT.M process does not hang if hiber_start() function is invoked with   #
# SIGALRMs being blocked. This is possible if hiber_start() is called as a result of interrupt an  #
# executing timer handler. In this test we instrument such conditions with the following scenario: #
#                                                                                                  #
#   1. Start a MUMPS process on a writeable database and write an update to create shared memory.  #
#   2. Change the permissions on the database to read-only.                                        #
#   3. Start another MUMPS process that reads a global to be attached to the shared memory.        #
#   4. Terminate the first MUMPS process.                                                          #
#   5. Make an external call from the second process. During that call start a timer to call a     #
#      specific handler function in the external C program.                                        #
#   6. Once invoked, the external timer handler will send a kill -15 to its own process and start  #
#      a long sleep.                                                                               #
#   7. When the process gets interrupted, it invokes generic_signal_handler(), which then goes to  #
#      gds_rundown(). Since this is now the last process attached to shared memory, yet unable to  #
#      write to the database header, it asks gtmsecshr to act on its behalf.                       #
#   8. The test ensures that gtmsecshr is not running when the first MUMPS process is started, so  #
#      the second process has to start the gtmsecshr server. During that time, it pauses for some  #
#      time, letting the server come up, and it is hiber_start() that is used for that pause.      #
#                                                                                                  #
####################################################################################################

# With 16K counter semaphore bump per process, the 32K counter overflow happens with one read-write and
# one read-only mumps process (that this test later starts) which defeats the purpose of the test
# (to ensure gtmsecshr is invoked to remove shm as part of rundown) as counter overflow skips shm removal
# in rundown. So prevent counter overflow by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

# Create a database.
$gtm_tst/com/dbcreate.csh mumps >&! db_create.out

# Ensure we can invoke call-outs.
if (($?gtt_cc_shl_options == "0") || ($?gt_ld_shl_options == "0")) then
	echo "TEST-E-FAIL, Cannot test external calls; either gtt_cc_shl_options or gt_ld_shl_options is undefined."
	exit 1
endif

# Compile and link the test program.
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/intrpt_timer_handler.c
$gt_ld_shl_linker ${gt_ld_option_output}libintrpt_timer_handler${gt_ld_shl_suffix} $gt_ld_shl_options intrpt_timer_handler.o $gt_ld_syslibs -L$gtm_dist -lyottadb

# Make sure libyottadb.so can be found.
if (! ($?LD_LIBRARY_PATH) ) setenv LD_LIBRARY_PATH ""
if (! ($?LIBPATH) ) setenv LIBPATH ""
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${gtm_dist}
setenv LIBPATH ${LIBPATH}:${gtm_dist}

# Define the environment and create a mapping table.
setenv GTMXC_ith intrpt_timer_handler.tab
echo "`pwd`/libintrpt_timer_handler${gt_ld_shl_suffix}" > $GTMXC_ith
cat >> $GTMXC_ith << EOF
ith:	void intrpt_timer_handler()
EOF

# Ensure that gtmsecshr is not running prior to the test.
$gtm_com/IGS $gtm_exe/gtmsecshr "STOP" >&! gtmsecshr_stop.out

# Save the start time (for syslog searching).
set time_before = `date +"%b %e %H:%M:%S"`

# Invoke the M routine driving the test.
$gtm_dist/mumps -run ith >&! mumps.out

# Wait for the child to be created.
$gtm_tst/com/wait_for_log.csh -waitcreation -log child_pid.outx -duration 60

# Wait for the child to terminate.
set child_pid = `cat child_pid.outx`
$gtm_tst/com/wait_for_proc_to_die.csh $child_pid 60

# Save the end time (for syslog searching).
set time_after = `date +"%b %e %H:%M:%S"`

# Both parent and child should have been terminated with a kill -15; check that.
$gtm_tst/com/check_error_exist.csh mumps.out FORCEDHALT
$gtm_tst/com/check_error_exist.csh ith.mje FORCEDHALT
\mv ith.mjex ith.outx

# Verify that GTMSECSHRDMNSTARTED for our version was printed in the syslog.
$gtm_tst/com/getoper.csh "$time_before" "" "secshr_in_syslog.txt" "" GTMSECSHRDMNSTARTED
$grep GTMSECSHRDMNSTARTED secshr_in_syslog.txt | $grep "$tst_ver" >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL, GTMSECSHRDMNSTARTED not found in operator log. Check secshr_in_syslog.txt."
endif

# Restore the database permissions.
chmod 666 mumps.dat

# Verify that the database is OK.
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
