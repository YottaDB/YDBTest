#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#######################################################################################################
# This test ensures that ctime(), localtime(), and other related function calls are protected against #
# nesting and cannot cause hangs. We accomplish this by firing up short-lived MUPIP processes that a  #
# concurrent M process is trying to kill with a SIGTERM signal. (SIGTERM results in a syslog message, #
# and the syslog() function internally uses the same functions as the aforementioned XXXtime()        #
# routines; this has been demonstrated to cause hangs before the GTM-6802 changes.)                   #
#######################################################################################################

# Create a database.
$gtm_tst/com/dbcreate.csh mumps > dbcreate.out

# Set a very low flush timer span for quick updates.
$gtm_dist/dse >& "dse.outx" << EOF
        find -region=DEFAULT
        change -fileheader -flush_time=1
        quit
EOF

# Launch a GT.M process that initiates two jobs, one that launches
# MUPIP processes, and another one that kills them.
($gtm_dist/mumps -run intrptxtime &) >&! intrptxtime.out

# Wait for the pids of child and parent.
$gtm_tst/com/wait_for_log.csh -waitcreation -log parent_pid.outx -duration 60
$gtm_tst/com/wait_for_log.csh -waitcreation -log child_pid.outx -duration 60

# Let the test run for 5 seconds.
sleep 5

# Kill both M processes.
set parent_pid = `cat parent_pid.outx`
set child_pid = `cat child_pid.outx`
$gtm_dist/mupip stop $child_pid >&! mupip_stop_child.out
$gtm_dist/mupip stop $parent_pid >&! mupip_stop_parent.out

# Make sure that both processes are dead.
$gtm_tst/com/wait_for_proc_to_die.csh $parent_pid 60
$gtm_tst/com/wait_for_proc_to_die.csh $child_pid 60

# In case processes were still alive when MUPIP STOP was delivered,
# we remove the FORCEDHALT messages from the logs, but keep the logs
# verifiable by the test system.
$grep FORCEDHALT intrptxtime.out >&! /dev/null
if (! $status) then
	$gtm_tst/com/check_error_exist.csh intrptxtime.out FORCEDHALT >&! check_forcedhalt_exists_in_parent.outx
endif
$grep FORCEDHALT intrptxtime.mje >&! /dev/null
if (! $status) then
	$gtm_tst/com/check_error_exist.csh intrptxtime.mje FORCEDHALT >&! check_forcedhalt_exists_in_child.outx
	# Rename the .mjex file to avoid false alarms.
	mv intrptxtime.mjex intrptxtime-child.outx
endif

# Under heavy load we might accumulate a backlog of MUPIP processes, so wait for up to 5 minutes for them to terminate.
@ i = 0
@ cnt = -1
while ((0 != $cnt) && ($i < 300))
	@ i = $i + 5
	$psuser >&! mupip_ps_list$i.outx
	@ cnt = `$grep "mupip journal -extract -forward mumps.mjl" mupip_ps_list$i.outx | wc -l`
	sleep 5
end
if (0 != $cnt) then
	echo "TEST-E-FAIL, Not all MUPIP processes have terminated."
endif

# Remove the journal extract files.
rm mumps.mjf* >&! rm_mjfs.outx

# Verify that the database is fine.
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
