#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test if a REQRUNDOWN is issued in the below scenario
# 1. Create a database
# 2. Set a global
# 3. While GT.M is up and running, issue kill -9
# 4. Invoke MUPIP FTOK to get the shared memory identifier of the running database
# 5. Cleanup the IPC shared memory identifier
# 6. Bring back GT.M and try to access the global
# 7. This should issue REQRUNDOWN error
# 8. Do rundown and re-access the global
#

# Make sure that journaling is turned off; otherwise instead of REQRUNDOWN we
# might see a different message
setenv gtm_test_jnl NON_SETJNL

$gtm_tst/com/dbcreate.csh mumps

# Generate an M file to run in background
cat << CAT_EOF >&! genfile.m
genfile	;
	Set ^a=1
	Write "Pass"
	Hang 300
CAT_EOF

# Run the M program
($gtm_exe/mumps -r genfile >&! genfile.out & ; echo $! >&! mumps_pid.log) >&! exec.out
set mumps_pid = `cat mumps_pid.log`

$gtm_exe/mumps -r waitforglobal

$gtm_exe/dse all -buff >&! flush.out

# Kill the running GT.M instance
$kill9 $mumps_pid

# Get the shared memory id
set shmid = `$gtm_exe/mupip ftok mumps.dat |& $grep mumps | $tst_awk '{print $6}'`

# Cleanup the shared memory identifier
$gtm_tst/com/ipcrm -m $shmid

# Access the global
$GTM << GTM_EOF >&! errormsg.out
Write ^a
GTM_EOF

# REQRUNDOWN error message will have the name of the machine (inclusive of .sanchez.com) which
# makes filtering out difficult. So, filter it to another file and use status to check if
# the error was indeed captured
$gtm_tst/com/check_error_exist.csh errormsg.out REQRUNDOWN ENO >&! err_capture.outx
set stat = $status

if !($stat) then
	echo "TEST-I-PASSED: REQRUNDOWN error found as expected."
else
	echo "TEST-E-FAILED: REQRUNDOWN error not found."
endif

# Do rundown and access the global again
$MUPIP rundown -reg "*"
$MUPIP rundown -relinkctl >& rundown_rlnk.outx # Also rundown relinkctl files (if any) leftover from the crash

$GTM << GTM_EOF
Write ^a
GTM_EOF

$gtm_tst/com/dbcheck.csh
