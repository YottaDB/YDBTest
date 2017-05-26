#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#######################################################################################
# Test that verifies that we are cutting the link to the previous-generation journal  #
# file upon a (simulated) system crash.                                               #
#######################################################################################

# Disable random journaling
setenv gtm_test_jnl NON_SETJNL

# Create a database
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

# Copy the database for future use with dbcheck
cp mumps.dat mumps.dat.bak

# Enable journaling
$MUPIP set $tst_jnl_str -reg "*" >&! mupip_set1.out

# Launch a GT.M process that simply kills itself
$gtm_exe/mumps -run setWcBlockedAndKillSelf >&! kill_self.out

# Get the semaphore and shared memory ids
$MUPIP ftok mumps.dat >&! ftok.out
set semid = `cat ftok.out | $grep "mumps.dat" | $tst_awk '{print $3}'`
set shmid = `cat ftok.out | $grep "mumps.dat" | $tst_awk '{print $6}'`

# Delete the semaphore and shared memory
$gtm_tst/com/ipcrm -s $semid
$gtm_tst/com/ipcrm -m $shmid

# Launch a GT.M process
$gtm_exe/mumps -direct >& "gtm.out" << EOF
set ^a=1
EOF

# Verify that REQRECOV message was printed in the GT.M prompt
$gtm_tst/com/check_error_exist.csh gtm.out REQRECOV ENO

# Do a MUPIP rundown with -override flag regardless of what the error message suggests
$MUPIP rundown -region "*" -override >& rundown.out

# Clean up the relinkcrl shared memory segments.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.outx

# Try to reenable journaling
$MUPIP set $tst_jnl_str -reg "*" >&! mupip_set2.out

# Ensure that the message about cutting the link is printed
$gtm_tst/com/check_error_exist.csh mupip_set2.out PREVJNLLINKCUT

# Now verify that the old journal file was left as crashed
echo "Old journal file:"
$MUPIP journal -show=header -noverify -forw mumps.mjl_* >&! mupip_journal_header1.out
cat mupip_journal_header1.out | $grep Crash
echo

echo "New journal file:"
# Also verify that the new journal file is not crashed and has the link to the old one cut
$MUPIP journal -show=header -noverify -forw mumps.mjl >&! mupip_journal_header2.out
cat mupip_journal_header2.out | $grep Crash
cat mupip_journal_header2.out | $grep "Prev journal file name"
echo

# Replace the rundown database with the clean one
cp mumps.dat mumps.dat.orig
cp mumps.dat.bak mumps.dat

# Verify that the database is fine
$gtm_tst/com/dbcheck.csh
