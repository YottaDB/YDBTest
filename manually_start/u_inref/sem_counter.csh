#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
# Each of the 32800 processes, when opening an encrypted database, has gpg-agent decrypt the database key. gpg-agent
# serves those requests one at a time, at about 0.4 seconds each, which stretches the subtest from minutes to hours.
setenv test_encryption NON_ENCRYPT
# UTF-8 mode adds about 0.3MB to each process, which is about 10GB over 32800 processes. That is enough to exhaust the
# memory of a 64GB host with a Debug build. The counter semaphore does not depend on the character set, so use M mode.
$switch_chset M >&! switch_chset.out
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps

echo "# Enable replication"

$MUPIP set -region "*" -journal=on,before -replic=on >& replic_on.out

echo "# Start passive source server"
source $gtm_tst/com/passive_start_upd_enable.csh >& passive_start.out

echo "# Start 34000 processes"
set syslog_start = `date +"%b %e %H:%M:%S"`
set oom_start = `date +"%Y-%m-%d %H:%M:%S"`
$gtm_exe/mumps -run semcounter

echo "# Wait for NOMORESEMCNT message"
# If semcounter stopped starting processes for lack of memory (TEST-E-MEMLOW) or because a batch did not attach to the
# database (TEST-E-STALLED), the counter cannot reach its maximum
if ((! -e semcounter_memlow.txt) && (! -e semcounter_stalled.txt)) then
	$gtm_tst/com/getoper.csh "$syslog_start" "" syslog1.txt "" NOMORESEMCNT
endif

echo "# Stop all the processes and wait for them to die"
$gtm_exe/mumps -run stop^semcounter

echo "# Verify that all the processes exited"
$gtm_exe/mumps -run check^semcounter
if (-e semcounter_alive.txt) then
	# A process still alive keeps the journal pool and database IPCs from being removed by the source server shutdown
	# and rollback below, which would leave them for later subtests to trip over. Stop each such process. A pid can be
	# reused once its process exits, so only signal a process whose working directory is this subtest's directory.
	set subtestdir = `/bin/pwd -P`
	foreach pid (`cat semcounter_alive.txt`)
		if ("$subtestdir" == "`readlink /proc/$pid/cwd`") kill -TERM $pid
	end
	$gtm_exe/mumps -run waitalive^semcounter
endif

echo "# Shutdown passive source server"
$MUPIP replicate -source -shutdown -timeout=0 >& passive_stop.out

echo "# Rollback to reset the counter overflow flags"
$MUPIP journal -rollback -backward "*" >& rollback.out

$gtm_tst/com/dbcheck.csh

# The OOM killer's messages go to the kernel log, which syslog1.txt above may not cover. Report any since the processes
# were started, as they explain processes killed or not exiting, whichever process the OOM killer chose.
journalctl -k --since "$oom_start" --no-pager -q |& grep "Out of memory: Killed process" >&! oomkills.txt
set noomkills = `wc -l < oomkills.txt`
if (0 != $noomkills) then
	echo "TEST-E-OOMKILL : the OOM killer killed $noomkills processes while this subtest ran. See oomkills.txt"
endif
