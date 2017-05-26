#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Make sure the basic R/O functionality of gtmsecshr works:
#
# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and prevents exercising gtmsecshr (the primary purpose of this test) so disable counter overflows
# in this test by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

unsetenv gtm_usesecshr		# Make sure not tracking db initialization
unsetenv gtm_procstuckexec	# No procstuckexec in this test - we expect these messages
setenv gtm_test_spanreg 0	# because there are only 2 regions and one of it is read-only, updates cannot span anyways.
$gtm_tst/com/dbcreate.csh mumps 2
$GTM << EOF			# Put a little bit of content into a.dat DB
For i=1:1:5 Set ^a(i)=i
EOF
chmod 444 a.dat			# DB is read-only now
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 66
set syslog_time1 = `date +"%b %e %H:%M:%S"`
#
# Note it is possible in the short period of time between when we stop any running gtmsecshr
# and start it again that some other test starts it without the flag we want enabled. Chances
# seem VERY low for that but not impossible. If it becomes an issue, we can get more
# extravagent.
#
$gtm_com/IGS $gtm_dist/gtmsecshr "STOP"	# Make sure secshr not running so we can start it with gtm_usesecshr
setenv gtm_usesecshr 1		# *ALWAYS* use secshr for lock wakeups, IPC cleanups, etc.
#
# Trace the secshr activity for our client process
#
$gtm_dist/mumps -run ^secshrtst
unsetenv gtm_usesecshr		# Turn off tracing again
#
# Save results that'll be overwritten in the next step
#
mkdir run1
cp -p client_pid.txt run1
cp -p mumps.dat run1
mv *.mjo* run1
mv *.mje* run1
#
# Extract syslog for that period
#
sleep 1           # Some separation so last msg out gets included
set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" syslog1.txt
echo "Range $syslog_time1 to $syslog_time2." >> syslog1.txt
set pid = `cat client_pid.txt`
#
# Extract related syslog messages - use client pid
#
$gtm_tst/$tst/u_inref/isolate_secshr_syslog.csh $pid syslog1.txt
#
# Now do much the same thing without the flag enabled to make sure we trace what we want.
#
$gtm_com/IGS $gtm_dist/gtmsecshr "STOP"	# Make sure secshr not running so we can start it
sleep 2           # Gives us some separation so no overlap between syslog1 and syslog2
set syslog_time3 = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run ^secshrtst
sleep 1           # Some separation so last msg out gets included
set syslog_time4 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time3" "$syslog_time4" syslog2.txt
echo "Range $syslog_time3 to $syslog_time4." >> syslog2.txt
set pid = `cat client_pid.txt`
$gtm_tst/$tst/u_inref/isolate_secshr_syslog.csh $pid syslog2.txt
#
chmod +w a.dat	# restore read-write permissions befor dbcheck just in case leftover_ipc_cleanup_if_needed.csh needs to be called
$gtm_tst/com/dbcheck.csh
