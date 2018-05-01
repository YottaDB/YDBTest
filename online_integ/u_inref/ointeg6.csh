#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2009, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest verifies that before-images written to the snapshot file are not in plain text
# when running with encryption, i.e., they are encrypted.
#
# 1. A db is created with encryption turned on
# 2. OLI is started with white box enabled so that we get enough time to do some parallel updates. -PRESERVE is provided so
#    that the temporary files are not deleted once INTEG completes.
# 3. Do database updates during the stall time. This would write before images to the temporary snapshot file
# 4. Once OLI completes, do 'strings' on the snapshot file to ensure the output does not contain the variables that were
#    before imaged during the OLI

# This white box test case will hold the online integ until signalled via the test sequence field in nl.

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 26
setenv gtm_white_box_test_case_count 1

# Go with dbg version as the white box test case is not enabled in pro version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver "dbg"

$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
set ^alongvariable=3
set ^blongvariable=5
h
EOF

$echoline
echo "# Kick off online integ in the background and have it wait once the snapshot is started."
$echoline
set ointeg1_1_log = "ointeg1_1.log"
set mupip_log1 = "mupip_log1.log"
($MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log1 & ; echo $! >! mupip1_pid.log) >&! $ointeg1_1_log
set mupip1_pid = `cat mupip1_pid.log`
set log1 = "log1.out"

$gtm_tst/com/waitforOLIstart.csh

$echoline
echo "# Now that snapshot is started, do some updates with ^alongvariable so that before image is written"
$echoline

$GTM << EOF
set ^alongvariable=6
EOF


$echoline
echo "# Signal the online integ to proceed"
$echoline
$DSE cache -change -offset=$hexoffset -size=4 -value=2 >>&! dse_change_offset.out

$echoline
echo "# Wait for background online integ to complete"
$echoline
$gtm_tst/com/wait_for_proc_to_die.csh $mupip1_pid 120 >&! proc_die.log
if ($status) then
	echo "# `date` TEST-E-TIMEOUT waited 120 seconds for online integ $mupip1_pid to complete."
	echo "# Exiting the test."
	exit
endif

$echoline
echo "# Verify that ^alongvariable is not present in the snapshot file"
$echoline
$strings ydb_snapshot_* | $grep "alongvariable"
set stat = $status
if (! $stat) then
	echo "# TEST-E-FAILED: Variable name 'alongvariable' is found in the temporary file though database is encrypted"
else
	echo "# TEST PASSED"
endif

$gtm_tst/com/dbcheck.csh
