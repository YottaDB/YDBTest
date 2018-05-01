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
# This subtest tests that MUPIP INTEG -ONLINE when shotdown in the middle followed by a rundown of the region ensures that
# temporary files are cleaned up

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 26
setenv gtm_white_box_test_case_count 1

# Go with dbg version as the white box test case is not enabled in pro version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver "dbg"

$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
set ^a=3
set ^b=5
h
EOF

$echoline
echo "# Kick off online integ in the background and have it wait once the snapshot is started."
$echoline
set ointeg1_1_log = "ointeg1_1.log"
set mupip_log1 = "mupip_log1.log"
($MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log1 & ; echo $! >! mupip1_pid.log) >&! $ointeg1_1_log
set mupip1_pid = `cat mupip1_pid.log`

$gtm_tst/com/waitforOLIstart.csh

$echoline
echo "# Now that the snapshot is started, issue kill -9 to bring down the ONLINE INTEG	   "
$echoline
$kill9 $mupip1_pid

$echoline
echo "# ONLINE INTEG is now shot down. Ensure that doing a rundown cleans up the temporary files"
$echoline
# Save snapshots in case we want to debug a failure
\mkdir bak_snapshot
cp ydb_snapshot_* bak_snapshot

ls -l ydb_snapshot* >&! ls_ydb_snapshot.log
set stat = $status
if !($stat) then
	echo "# Snapshot temporary files found before rundown as expected"
endif
$MUPIP rundown -reg "*"
ls -l ydb_snapshot* >>&! ls_ydb_snapshot.log
set stat = $status
if ($stat) then
	echo "# Snapshot temporary files NOT found after rundown as expected"
endif

$gtm_tst/com/dbcheck.csh
