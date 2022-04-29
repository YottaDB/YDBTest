#!/bin/sh
#################################################################
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
#
# Routine to cause a DBPRIVERR error to be raised which usually logs to the syslog unless the userid's group is listed
# in a LOGDENIALS statement in $ydb_dist/restrict.txt. Note this is run with the restrict.txt file have a LOGDENIALS
# statement with a group of ydbtest3 so if running a non-ydbtest3 userid, this should create a logentry in syslog.
# If a LOGDENIALS statement does not exist (or restrict.txt does not exist or the process has write privileges), then
# the message is logged everywhere. In all cases of this test though, LOGDENIALS is always set to ydbtest3.
#
# Note this script is running in an su - <uid> session with nothing setup so do any setup we want done ourselves.
#
echo "Running with userid $USER"
export ydb_dist="$*"
export gtm_dist="$ydb_dist"
export ydb_gbldir="mumps.gld"
export gtmgbldir="$ydb_gbldir"
export ydb_routines=". $ydb_dist"
export gtmroutines="$ydb_routines"
export ydb_debug_flg1="1"
# Drive YDB with a statement to change the global directory to something that does not exist
$ydb_dist/mumps -run ^%XCMD 'write "DrivePID: ",$job,! set ^x=1'
exit $status

