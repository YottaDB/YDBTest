#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###################################################################################################################################
# Usage: setjnlpooltnvar <var>
#
# Utility alias. Sets the value of <var> to the current "last transaction written" number for the instance.
# Uses "backlog_ver" variable to get unique temporary files.
###################################################################################################################################

###################################################################################################################################

alias dumpbacklog '$MUPIP replicate -source -showbacklog >& backlog_$backlog_ver.out'
alias getjnlpooltn 'dumpbacklog ; $tst_awk '"'"'/last transaction written/ {print $1}'"'"' < backlog_${backlog_ver}.out'
alias setjnlpooltnvar '@ backlog_ver++ ; @ \!:1 = `getjnlpooltn`'

###################################################################################################################################

unsetenv gtm_test_freeze_on_error		# disable ENOSPC testing because we can have problems due to gtm_custom_errors
						# being /dev/null (instance does not freeze and fails with JNLACCESS)
unsetenv gtm_test_fake_enospc
unsetenv gtm_test_jnlfileonly			# otherwise the source server can get hung on crit trying to open journal files
unsetenv gtm_test_jnlpool_sync			# ditto
setenv gtm_custom_errors "/dev/null"		# force instance freeze support

###################################################################################################################################

echo ""
echo "# Create Database"
echo ""

# This test manually does an instance freeze and then expects a checkhealth to succeed.
# But a checkhealth happens to cause the overflow if gtm_db_counter_sem_incr value is 4K or 8K (also depends on the number of helpers randomly chosen)
# And so that needs to flush the overflow to the db file header which will hang because the instance is frozen
# Hence disabling gtm_db_counter_sem_incr for this subtest if run in replic mode
if ($?test_replic) then
	unsetenv gtm_db_counter_sem_incr
	$MULTISITE_REPLIC_PREPARE 2
endif

if (! $?test_replic) setenv gtm_repl_instance "mumps.repl"
setenv gtm_test_mupip_set_version "disable"			# Getting some odd effects from V4 upgrade, so disable
# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh

$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000 >&! dbcreate.out

echo ""
echo "# Replication Setup"
echo ""

unsetenv gtm_repl_instance
$MUPIP set -region "*" -journal=before -replic=on >&! journalcfg.out
setenv gtm_repl_instance mumps.repl
if ($?test_replic) then
	$MSR START INST1 INST2 RP >&! msr_start_`date +%H_%M_%S`.out
	get_msrtime
	set start_time=$time_msr
else
	# source this to get start_time variable
	source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out
endif
$gtm_tst/com/backup_for_mupip_rollback.csh # Needed for test_replic=1 because replication has been explicitly
					   # turned on before calling $MSR START in the test_replic=1 case.
					   # Needed for test_replic=0 because this test does rollback even in this case.

echo ""
echo "# Start Workers"
echo ""

setenv gtm_test_jobid 1
setenv gtm_test_dbfillid 1
$gtm_tst/com/imptp.csh 4 >&! imptp_${gtm_test_jobid}.out

@ max_sleep = 300		# 30 was insufficient on a slower box
setjnlpooltnvar start_tno
@ end_tno = $start_tno + 1000

@ sleep_count = 0
setjnlpooltnvar cur_tno

while($cur_tno < $end_tno)
	if ($sleep_count == $max_sleep) then
		if ($cur_tno == $start_tno) then
			echo "TEST-E-TIMEOUT, No Transactions in Allotted Time (before freeze)"
			goto error
		else
			echo "TEST-I-TIMEOUT, Insufficient Number of Transactions in Allotted Time (before freeze)"
			break
		endif
	endif
	@ sleep_count++
	sleep 1
	setjnlpooltnvar cur_tno
end

echo ""
echo "# Freeze"
echo ""

# Freeze the instance while we have workers running

set syslog_before1 = `$gtm_dist/mumps -run timestampdh -1`

$MUPIP replicate -source -freeze=on -nocomment >&! freeze.out

# make sure we can go 10 seconds without getting any more transactions due to the freeze

setjnlpooltnvar before_tno
sleep 10
setjnlpooltnvar after_tno

set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window1.txt

if ($before_tno != $after_tno) then
	echo "TEST-E-BADFREEZE, Got `expr $after_tno - $before_tno` Transactions After Freeze"
	goto error
endif

$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "REPLINSTFROZEN"

echo ""
echo "# Start Additional Workers"
echo ""

# Start more workers to make sure that new arrivals will see the freeze and not make updates

setenv gtm_test_jobid 2
setenv gtm_test_dbfillid 2
# This needs to run in the background because the instance is frozen and the job framework
# tries to updata the database before starting jobs, leading to a hang. We want to verify
# that the hang occurs and resumes later after the freeze is lifted.
#
# Run background process under /bin/sh to avoid job control output
/bin/sh -c "$gtm_tst/com/imptp.csh 4 > imptp_${gtm_test_jobid}.out 2>&1 &"

# make sure we can go another 10 seconds without getting any more transactions due to the freeze

sleep 10
setjnlpooltnvar after_tno

if ($before_tno != $after_tno) then
	echo "TEST-E-BADFREEZE, Got `eval $after_tno - $before_tno` Transactions After Freeze and Additional Workers"
	goto error
endif

echo ""
echo "# Unfreeze"
echo ""

set syslog_before2 = `$gtm_dist/mumps -run timestampdh -1`

$MUPIP replicate -source -freeze=off >&! unfreeze.out

# Make sure source server is unfrozen after unfreeze command
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message REPLINSTUNFROZEN

# Verify that the workers wake up and complete transactions after unfreezing.

@ max_sleep = 300
@ sleep_count = 0
setjnlpooltnvar cur_tno

while ($cur_tno == $before_tno)
	if ($sleep_count == $max_sleep) then
		echo "TEST-E-TIMEOUT, No Transactions in Allotted Time (after unfreeze)"
		goto error
	endif
	@ sleep_count++
	sleep 1
	setjnlpooltnvar cur_tno
end

set syslog_after2 = `date +"%b %e %H:%M:%S"`
echo $syslog_before2 $syslog_after2 > time_window2.txt

$gtm_tst/com/getoper.csh "$syslog_before2" "" syslog2.txt "" "REPLINSTUNFROZEN"

# Make sure second imptp job started

setenv gtm_test_jobid 2
setenv gtm_test_dbfillid 2
@ max_sleep = 600		# 300 was a little short on some slower machines under load; normal case will be much shorter
$gtm_exe/mumps -r '%XCMD' "do startwait^gtm4525b(${gtm_test_dbfillid},${max_sleep})" >&! imptp_start_wait_${gtm_test_dbfillid}.out

echo ""
echo "# Stop Workers"
echo ""

# Stop the world and check that all is well before moving on.

setenv gtm_test_jobid 1
setenv gtm_test_dbfillid 1
$gtm_tst/com/endtp.csh >&! endtp_${gtm_test_jobid}.out
$gtm_tst/com/checkdb.csh

setenv gtm_test_jobid 2
setenv gtm_test_dbfillid 2
$gtm_tst/com/endtp.csh >&! endtp_${gtm_test_jobid}.out
$gtm_tst/com/checkdb.csh

echo ""
echo "# Start New Workers"
echo ""

# We need active processes hitting the database to be able to restart the source server
# and preserve the journal pool, so start some more.

setenv gtm_test_jobid 3
setenv gtm_test_dbfillid 3
$gtm_tst/com/imptp.csh 4 >&! imptp_${gtm_test_jobid}.out

echo ""
echo "# Freeze for Source Restart"
echo ""

$MUPIP replicate -source -freeze=on -nocomment

echo ""
echo "# Stop Source Server"
echo ""

# The instance was frozen, which generated a REPLINSTFROZEN message, unfrozen, then frozen
# again, which generated a second REPLINSTFROZEN message.
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message REPLINSTFROZEN -count 2

if ($?test_replic) then
	# the checkhealth would fail because we are frozen, so skip it
	setenv gtm_test_repl_skipsrcchkhlth 1
	# we still have mumps processes running, so tell STOPSRC not to complain about it
	setenv gtm_test_other_bg_processes 1
	$MSR STOPSRC INST1 INST2 >&! msr_stopsrc_`date +%H_%M_%S`.out
	unsetenv gtm_test_repl_skipsrcchkhlth gtm_test_other_bg_processes
else
	$MUPIP replicate -source -shutdown -timeout=0 >&! replicrestart.out
endif

$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log REPLINSTFROZEN

echo ""
echo "# Start Source Server on Frozen Instance"
echo ""

# the checkhealth would fail because we are frozen, so skip it
setenv gtm_test_repl_skipsrcchkhlth 1

if ($?test_replic) then
	$MSR STARTSRC INST1 INST2 RP >&! msr_startsrc_`date +%H_%M_%S`.out
	get_msrtime
	set start_time=$time_msr
else
	# calling mupip set would cause a hang before starting the server, so skip it
	setenv gtm_test_repl_skipsetreplic 1
	# source this to get start_time variable
	source $gtm_tst/com/passive_start_upd_enable.csh >&! frozen_start.out
	unsetenv gtm_test_repl_skipsetreplic
endif

unsetenv gtm_test_repl_skipsrcchkhlth

# Make sure that the source server started.

$MUPIP replicate -source -checkhealth >&! frozen_start_health.out
$grep -Eq "alive in (ACTIVE|PASSIVE) mode" frozen_start_health.out
if ($status) then
	echo "TEST-E-NOTFOUND, expected 'alive in (ACTIVE|PASSIVE) mode' in frozen_start_health.out"
endif
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message REPLINSTFROZEN

# Verify that we are still frozen
@ still_frozen=1
$MUPIP replicate -source -freeze >&! check_still_frozen_${still_frozen}.outx \
	&& echo "TEST-E-NOTFROZEN, expected freeze to be set, but isn't. See check_still_frozen_${still_frozen}.outx."

echo ""
echo "# Unfreeze"
echo ""

$MUPIP replicate -source -freeze=off >&! unfreeze_frozen_start.out

# Make sure source server is unfrozen after unfreeze command
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message REPLINSTUNFROZEN

# Stop the world and check that all is well before moving on.

$gtm_tst/com/endtp.csh >&! endtp_${gtm_test_jobid}.out
$gtm_tst/com/checkdb.csh

echo ""
echo "# Restart Workers"
echo ""

# Generate some background activity while we run the last batch of tests.

setenv gtm_test_jobid 4
setenv gtm_test_dbfillid 4
setenv gtm_test_crash 1
$gtm_tst/com/imptp.csh 4 >&! imptp_${gtm_test_jobid}.out

# Wait for some progress before proceeding.

@ max_sleep = 300		# 30 was insufficient on a slower box
setjnlpooltnvar start_tno
@ end_tno = $start_tno + 100

@ sleep_count = 0
setjnlpooltnvar cur_tno

while($cur_tno < $end_tno)
	if ($sleep_count == $max_sleep) then
		if ($cur_tno == $start_tno) then
			echo "TEST-E-TIMEOUT, No Transactions in Allotted Time (before additional freeze)"
			goto error
		else
			echo "TEST-I-TIMEOUT, Insufficient Number of Transactions in Allotted Time (before additional freeze)"
			break
		endif
	endif
	@ sleep_count++
	sleep 1
	setjnlpooltnvar cur_tno
end

echo ""
echo "# Freeze for Additional Tests"
echo ""

$MUPIP replicate -source -freeze=on -nocomment >&! freeze_crash.out

echo ""
echo "# Make a filehader change using DSE"
echo ""

$DSE change -fileheader -nocrit -flush_time=00:00:15:00 >&! dse_change.out

if ("" == `$DSE dump -nocrit -fileheader |& tee -a dse_change.out | $grep "Flush timer.*00:00:15:00"`) then
    echo "TEST-E-FAIL, DSE could not change header under freeze. Please check dse_change.out"
endif

echo ""
echo "# Shutdown Source"
echo ""

# We are going to test a rundown, so stop the source server and crash the workers
# so that it should succeed, were it not for the instance freeze.

# The instance was frozen when started, which generated a REPLINSTFROZEN message, unfrozen,
# then frozen again, which generated a second REPLINSTFROZEN message.
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message REPLINSTFROZEN -count 2

if ($?test_replic) then
	# we still have mumps processes running, so tell STOPSRC not to complain about it
	setenv gtm_test_other_bg_processes 1
	$MSR STOPSRC INST1 INST2 >&! msr_stopsrc_`date +%H_%M_%S`.out
	unsetenv gtm_test_other_bg_processes
else
	$MUPIP replicate -source -shutdown -timeout=0 >&! replicshutdown_crash.out
endif

# Verify that we are still frozen
@ still_frozen++
$MUPIP replicate -source -freeze >>&! check_still_frozen_${still_frozen}.outx \
	&& echo "TEST-E-NOTFROZEN, expected freeze to be set, but isn't. See check_still_frozen_${still_frozen}.outx."

$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log REPLINSTFROZEN

echo ""
echo "# Crash Workers"
echo ""

# We are going to test a rundown, so stop the source server and crash the workers
# so that it should succeed, were it not for the instance freeze.

source ./gtm_test_crash_jobs_${gtm_test_jobid}.csh

foreach MJE ( impjob_imptp${gtm_test_jobid}.mje? )
	# Make sure the message shows up before we strip it. Saw this race lost on thermo.
	$gtm_tst/com/wait_for_log.csh -message FORCEDHALT -log $MJE
	# Strip FORCEDHALT messages
	$gtm_tst/com/check_error_exist.csh $MJE FORCEDHALT
	# Rename *.mje?x to *.xmje? to avoid the errors from errors.csh
	mv ${MJE}x ${MJE:s/.mje/.xmje/}
end

# Verify that we are still frozen
@ still_frozen++
$MUPIP replicate -source -freeze >>&! check_still_frozen_${still_frozen}.outx \
	&& echo "TEST-E-NOTFROZEN, expected freeze to be set, but isn't. See check_still_frozen_${still_frozen}.outx."

echo ""
echo "# Attempt mupip set on Frozen Instance"
echo ""

($MUPIP set -region "*" -journal=before -replic=on >&! set_frozen.out & ; echo $! >! mupip_set_pid.out)	>> mupip_set_bkgrnded.out
$gtm_tst/com/wait_for_log.csh -message MUINSTFROZEN -log set_frozen.out -duration 60

# Verify that we are still frozen
@ still_frozen++
$MUPIP replicate -source -freeze >>&! check_still_frozen_${still_frozen}.outx \
	&& echo "TEST-E-NOTFROZEN, expected freeze to be set, but isn't. See check_still_frozen_${still_frozen}.outx."

echo ""
echo "# Unfreeze"
echo ""

$MUPIP replicate -source -freeze=off >&! unfreeze_crash.out

$gtm_tst/com/wait_for_log.csh -message MUINSTUNFROZEN -log set_frozen.out -duration 60
if (0 == $status) then
	echo "MUINSTFROZEN and MUINSTUNFROZEN message seen as expected"
else
	echo "TEST-E-FAIL, MUINSTFROZEN not seen in the log"
endif
set mupip_set_pid = `cat mupip_set_pid.out`
$gtm_tst/com/wait_for_proc_to_die.csh $mupip_set_pid 300 >&! wait_for_proc_to_die.out

echo ""
echo "# Rollback"
echo ""

# This should succeed.

$gtm_tst/com/mupip_rollback.csh '*' >&! rollback.out

echo ""
echo "# Final Check"
echo ""

# We can legitimately get abandoned kills because of the way we crash the workers
# while frozen, so use dbcheck_filter to ignore those.
# ONLINE INTEG leads to assertion failures in the DBFGTBC/DBTOTBLK case, so
# avoid them by disabling online.

if ($?test_replic) then
	# Make sure receiver gets everything so that the extract check will match
	$MSR STARTSRC INST1 INST2 RP >&! msr_start_`date +%H_%M_%S`.out

	# Freeze secondary, just to show we can
	$MSR RUN INST2 'date +"%b %e %H:%M:%S" >& syslog_before_3.out ; $MUPIP replicate -source -freeze=on -comment=JustTesting' >& freeze_secondary.out
	$MSR RUN INST2 '$gtm_tst/com/getoper.csh "`cat syslog_before_3.out`" "" syslog3.txt "" "REPLINSTFROZEN"' >& freeze_secondary_syslog.out
	$MSR RUN INST2 '$MUPIP replicate -source -freeze'
	$MSR RUN INST2 '$MUPIP replicate -source -checkhealth'
	$MSR RUN INST2 'date +"%b %e %H:%M:%S" >& syslog_before_4.out ; $MUPIP replicate -source -freeze=off' >& unfreeze_secondary.out
	$MSR RUN INST2 '$gtm_tst/com/getoper.csh "`cat syslog_before_4.out`" "" syslog4.txt "" "REPLINSTUNFROZEN"' >& unfreeze_secondary_syslog.out
	$MSR RUN INST2 '$MUPIP replicate -source -freeze'
	$MSR RUN INST2 '$MUPIP replicate -source -checkhealth'

	$gtm_tst/com/dbcheck_filter.csh -extract -noonline >&! dbcheck.out
else
	$gtm_tst/com/dbcheck_filter.csh -noonline >&! dbcheck.out
endif

# dbcheck currently trips over several errors that either need to be avoided in the code
# or repaired using a rollback/resync. Rather than doing a resync all the time, just ignore
# the output files if they contain the offending errors. Filtering the messages out wouldn't
# be any better since the dbcheck is useless at this point.
set dbcheck_out_files=(dbcheck.out mupip.err)
if ($?test_replic) then
	set dbcheck_out_files=($dbcheck_out_files `cat dbcheck_msr_execute_base_INST1_out.txt`)
endif
foreach f ($dbcheck_out_files)
	if (-f $f) then
		$grep -Eq 'DBMBMINCFRE|DBFGTBC|DBTOTBLK' ${f} && mv ${f} ${f:r}.x${f:e}x
	endif
end

echo ""
echo "# Done"

exit 0

error:
	set echo verbose
	$MUPIP replicate -source -freeze=off
	foreach i (1 2 3 4)
		setenv gtm_test_jobid $i
		setenv gtm_test_dbfillid $i
		$gtm_tst/com/endtp.csh
	end
	if ($?test_replic) then
		$MSR STOP INST1 INST2
	else
		$MUPIP replicate -source -shutdown -timeout=0
	endif
	exit 1
