#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#######################################################################################
# Helper script for rundown_override subtest. Verifies changes to MUPIP RUNDOWN that  #
# prevent running down the database if journaling is enabled, unless a specific       #
# override qualifier is provided.                                                     #
#######################################################################################

# Get the case number.
set case = $1

echo "Case${case}"

# Create a database.
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate${case}.out

# Copy the database for future use with dbcheck.
cp mumps.dat mumps.dat.bak

# Enable journaling.
$MUPIP set -journal=enable,on,before -reg "*" >&! mupip_set${case}.out

# Launch a GT.M process that simply kills itself.
$gtm_exe/mumps -direct >&! kill_self${case}.out <<EOF
	write "PID is "_\$job,!
	set ^a=1
	zsystem "$kill9 "_\$job
EOF

if (2 == $case) then
	# Get the semaphore and shared memory ids.
	$MUPIP ftok mumps.dat >&! ftok.out
	set semid = `cat ftok.out | $grep "mumps.dat" | $tst_awk '{print $3}'`
	set shmid = `cat ftok.out | $grep "mumps.dat" | $tst_awk '{print $6}'`

	# Delete the semaphore and shared memory.
	$gtm_tst/com/ipcrm -s $semid
	$gtm_tst/com/ipcrm -m $shmid

	# Launch a GT.M process.
	$gtm_exe/mumps -direct >& "gtm${case}.out" << EOF
	set ^a=1
EOF

	# Verify that REQRECOV message was printed in the GT.M prompt.
	$gtm_tst/com/check_error_exist.csh gtm${case}.out REQRECOV ENO
endif

# Do a MUPIP rundown without -override flag.
$MUPIP rundown -region "*" >& rundown${case}a.out

# Verify that MUUSERECOV message was issued.
$gtm_tst/com/check_error_exist.csh rundown${case}a.out MUUSERECOV MUNOTALLSEC

# Because the GT.M process might have been killed during the transition of a record
# between the active and free queues, avoid tripping on an unlikely assert.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

# Do a MUPIP rundown with -override flag.
$MUPIP rundown -region "*" -override >& rundown${case}b.out

# Unset the temporary white-box test.
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_enable

# Verify that the second rundown succeeded.
$grep SHMREMOVED rundown${case}b.out
$grep MUFILRNDWNSUC rundown${case}b.out
echo

# Replace the rundown database with the clean one.
cp mumps.dat mumps.dat.orig
cp mumps.dat.bak mumps.dat

# Verify that the database is fine.
$gtm_tst/com/dbcheck.csh

# Prepare for the next case.
set dir = "case${case}"
$gtm_tst/com/backup_dbjnl.csh $dir
echo
