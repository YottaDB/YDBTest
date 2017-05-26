#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Helper routine for the mupip_rundown_ipcs subtest. It is responsible for testing one particular configuration, as provided
# by the master script, and printing a failure notification in case some of our expectations are not met.

set case = $1

# Conditions.
set keep_shared_memory = $2
set keep_ftok_semaphore = $3
set keep_access_semaphore = $4
set mupip_rundown_has_args = $5

# Expectations.
set shared_memory_should_be_gone = $6
set ftok_sem_should_be_gone = $7
set access_sem_should_be_gone = $8
set mupip_should_error = $9

$echoline
echo "Case $case"
echo "Keeping shared memory: $keep_shared_memory"
echo "Keeping FTOK semaphore: $keep_ftok_semaphore"
echo "Keeping access semaphore: $keep_access_semaphore"
echo "MUPIP RUNDOWN has args: $mupip_rundown_has_args"
$echoline

echo "Creating a database..."
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate${case}.out
echo

echo "Enabling journaling..."
$MUPIP set $tst_jnl_str -reg "*" >&! mupip_set${case}.out
echo

echo "Firing up a process that kills self..."
$gtm_dist/mumps -run %XCMD 'write "PID is "_$job,! set ^a=1 if $zsigproc($job,9)' >&! kill_self${case}.out
echo

# Get the semaphore and shared memory ids.
$MUPIP ftok mumps.dat >&! mupip_ftok${case}.out
set semid = `cat mupip_ftok${case}.out | $grep "mumps.dat" | $tst_awk '{print $3}'`
set shmid = `cat mupip_ftok${case}.out | $grep "mumps.dat" | $tst_awk '{print $6}'`

# Saving the status of our IPCs as well as the ID of the FTOK semaphore.
$gtm_tst/com/check_ipcs.csh all >&! check_ipcs${case}a.outx
set ftok_semid = `$grep -E -v "(CHECK|$semid|$shmid)" check_ipcs${case}a.outx | $tst_awk '{print $2}'`

if (! $keep_shared_memory) then
	echo "Removing the shared memory..."
	$gtm_tst/com/ipcrm -m $shmid
	echo
endif

if (! $keep_access_semaphore) then
	echo "Removing the access semaphore..."
	$gtm_tst/com/ipcrm -s $semid
	echo
endif

if (! $keep_ftok_semaphore) then
	echo "Removing the ftok semaphore..."
	$gtm_tst/com/ipcrm -s $ftok_semid
	echo
endif

$MUPIP rundown -relinkctl >&! mupip_rundown_rctl${case}.outx

# Because the GT.M process might have been killed during the transition of a record
# between the active and free queues, avoid tripping on an unlikely assert.
setenv gtm_white_box_test_case_number 29

if ($mupip_rundown_has_args) then
	set mupip_rundown_region = `$gtm_exe/mumps -run %XCMD 'write $random(2)'`
	if ($mupip_rundown_region) then
		echo "Running MUPIP RUNDOWN -REGION *..."
		$MUPIP rundown -region "*" >& mupip_rundown${case}a.out
	else
		echo "Running MUPIP RUNDOWN -FILE MUMPS.DAT..."
		$MUPIP rundown -file mumps.dat >& mupip_rundown${case}a.out
	endif
else
	echo "Running MUPIP RUNDOWN..."
	$MUPIP rundown >& mupip_rundown${case}a.out
endif
echo

# If we do not expect errors from our test, but use argumentless RUNDOWN, we might still get errors from
# other concurrently running tests.
echo "Verifying whether MUUSERECOV and MUNOTALLSEC are issued..."
if ($mupip_should_error) then
	$gtm_tst/com/check_error_exist.csh mupip_rundown${case}a.out MUUSERECOV MUNOTALLSEC
	if (! $mupip_rundown_has_args) then
		mv mupip_rundown${case}a.out mupip_rundown${case}a.orig.outx
	endif
else
	if ($mupip_rundown_has_args) then
		$grep -E -q "MUNOTALLSEC" mupip_rundown${case}a.out
		if (! $status) then
			echo "TEST-E-FAIL, MUPIP command should not have errored out but did."
		endif
	else
		mv mupip_rundown${case}a.out mupip_rundown${case}a.orig.outx
	endif
endif
echo

# Reacquire the IPCs status after the operation.
$gtm_tst/com/check_ipcs.csh all >&! check_ipcs${case}b.outx

echo "Verifying the status of shared memory..."
$grep -q $shmid check_ipcs${case}b.outx
set shared_memory_gone = $status
if ($shared_memory_should_be_gone && (! $shared_memory_gone)) then
	echo "TEST-E-FAIL, Shared memory should be gone but is present."
else if ((! $shared_memory_should_be_gone) && $shared_memory_gone) then
	echo "TEST-E-FAIL, Shared memory should be present but is gone."
endif
echo

echo "Verifying the status of FTOK semaphore..."
$grep -q $ftok_semid check_ipcs${case}b.outx
set ftok_sem_gone = $status
if ($ftok_sem_should_be_gone && (! $ftok_sem_gone)) then
	echo "TEST-E-FAIL, FTOK semaphore should be gone but is present."
else if ((! $ftok_sem_should_be_gone) && $ftok_sem_gone) then
	echo "TEST-E-FAIL, FTOK semaphore should be present but is gone."
endif
echo

echo "Verifying the status of access semaphore..."
$grep -q $semid check_ipcs${case}b.outx
set access_sem_gone = $status
if ($access_sem_should_be_gone && (! $access_sem_gone)) then
	echo "TEST-E-FAIL, Access semaphore should be gone but is present."
else if ((! $access_sem_should_be_gone) && $access_sem_gone) then
	echo "TEST-E-FAIL, Access semaphore should be present but is gone."
endif
echo

set mupip_rundown_override_option = `$gtm_exe/mumps -run %XCMD 'write $random(3)+1'`
if (1 == $mupip_rundown_override_option) then
	echo "Running MUPIP RUNDOWN -OVERRIDE..."
	$MUPIP rundown -override >& mupip_rundown${case}b.outx
else if (2 == $mupip_rundown_override_option) then
	echo "Running MUPIP RUNDOWN -FILE MUMPS.DAT -OVERRIDE..."
	$MUPIP rundown -file mumps.dat -override >& mupip_rundown${case}b.outx
else
	echo "Running MUPIP RUNDOWN -REGION * -OVERRIDE..."
	$MUPIP rundown -region "*" -override >& mupip_rundown${case}b.outx
endif
echo

echo "Rechecking the status of IPCS..."
$gtm_tst/com/check_ipcs.csh all
echo

# Unset the temporary white-box test.
unsetenv gtm_white_box_test_case_number

echo "Backing files up..."
set dir = "case${case}"
$gtm_tst/com/backup_dbjnl.csh $dir

# Note that there is no point running a dbcheck.csh on a crashed database.

echo
echo
