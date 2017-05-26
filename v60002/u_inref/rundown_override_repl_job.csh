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
# prevent running down the database if replication is enabled, unless a specific      #
# override qualifier is provided.                                                     #
#######################################################################################

# Get the case number.
set case = $1

echo "Case${case}"

# Make sure we have before image journaling.
source $gtm_tst/com/gtm_test_setbeforeimage.csh

# Prepare to use MSR framework with two instances.
$MULTISITE_REPLIC_PREPARE 2

# Create a database.
$gtm_tst/com/dbcreate.csh mumps > dbcreate${case}.out

# Copy the database for future use with dbcheck.
$MSR RUN INST2 'cp mumps.dat mumps.dat.bak'

# Start both instances.
$MSR START INST1 INST2 RP
echo

# Launch a GT.M process to write some updates.
$gtm_exe/mumps -direct >& "gtm${case}a.out" << EOF
set ^a=1
EOF

# Crash the secondary.
if (3 == $case) then
	# Keep the IPCs.
	$MSR CRASH INST2 NO_IPCRM
else
	# Remove the IPCs.
	$MSR CRASH INST2
endif
echo

# Try to start the receiver; should get an error message.
$MSR STARTRCV INST1 INST2
echo

# Verify that REQROLLBACK message was printed in the START_* file.
set last_start_log = `ls -ltr $SEC_SIDE/START_* | $tail -1 | $tst_awk '{print $9}'`
$gtm_tst/com/check_error_exist.csh $last_start_log REPLREQROLLBACK ENO JNL_ON-E-MUPIP

# Verify that expected messages in the journal log are printed.
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/jnl.log REQROLLBACK ENO MUNOFINISH JNL_ON-E-MUPIP
echo

# Do a MUPIP RUNDOWN without override option on the secondary.
$MSR RUN INST2 '$MUPIP rundown -region "*" >>&! rundown'${case}'a.out'
echo

# Verify that MUUSERLBK message was issued.
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/rundown${case}a.out MUUSERLBK MUNOTALLSEC
echo

# Do a MUPIP RUNDOWN with an override qualifier on the secondary, also making sure to
# set a white-box environment variable that avoids an unlikely assert in case a prior
# process died during the transition of a record between the active and free queues.
$MSR RUN INST2 'setenv gtm_white_box_test_case_enable 1 ; setenv gtm_white_box_test_case_number 29 ; $MUPIP rundown -region "*" -override >>&! rundown'${case}'b.out'
echo

# Verify that the second rundown succeeded.
$grep SHMREMOVED $SEC_SIDE/rundown${case}b.out
$grep MUFILRNDWNSUC $SEC_SIDE/rundown${case}b.out
echo

# Now that the secondary is down, stop the primary only.
$MSR STOP INST1
echo

# Replace the rundown database with the clean one.
$MSR RUN INST2 'cp mumps.dat mumps.dat.orig; cp mumps.dat.bak mumps.dat'
echo

# Verify that the database is fine.
$gtm_tst/com/dbcheck.csh
echo

# Prepare for the next case.
set dir = "case${case}"
mkdir $dir
\mv *.dat $dir
\mv *.mjl* $dir
\mv *.gld $dir

# Also move things out of the way on the secondary.
$MSR RUN INST2 'mkdir '$dir'; mv *dat '$dir'; mv *.mjl* '$dir'; mv *.gld '$dir
if (1 == $test_replic_suppl_type) then
	$MSR RUN INST2 'set msr_dont_trace ;set suppl_port = `cat portno_supp` ;$gtm_tst/com/portno_release.csh $suppl_port'
endif
echo
