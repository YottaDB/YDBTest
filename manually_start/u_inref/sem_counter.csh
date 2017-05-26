#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_qdbrundown 1
# passive_start_upd_enable.csh needs the following to be set
setenv gtm_test_qdbrundown_parms "-qdbrundown"
# we are launching enough processes to overflow counters so disable artificial bumps
unsetenv gtm_db_counter_sem_incr
setenv gtm_test_jnl SETJNL
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps

echo "# Enable replication"

$MUPIP set -region "*" -journal=on,before -replic=on >& replic_on.out

echo "# Start passive source server"
source $gtm_tst/com/passive_start_upd_enable.csh >& passive_start.out

echo "# Start 34000 processes"
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run semcounter

echo "# Wait for NOMORESEMCNT message"
$gtm_tst/com/getoper.csh "$syslog_start" "" syslog1.txt "" NOMORESEMCNT

echo "# Stop all the processes and wait for them to die"
$gtm_exe/mumps -run stop^semcounter

echo "# Shutdown passive source server"
$MUPIP replicate -source -shutdown -timeout=0 >& passive_stop.out

echo "# Rollback to reset the counter overflow flags"
$MUPIP journal -rollback -backward "*" >& rollback.out

$gtm_tst/com/dbcheck.csh
