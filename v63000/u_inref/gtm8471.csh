#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

echo "# Take away write permission to trigger gtmsecshr"
chmod u-w mumps.dat

echo "# Do an update"
set syslog_start = `date +"%b %e %H:%M:%S"`
# Filter out DBPRIVERR since it is expected due to lack of write permission
env gtm_autorelink_ctlmax=800000 $gtm_exe/mumps -run %XCMD 'set ^x=1' |& $grep -v DBPRIVERR

echo "# Look for ARCTLMAXLOW"
sleep 5  # Give a chance for messages to trigger
$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog1.txt" ""
$grep ARCTLMAXLOW syslog1.txt
if (0 == $status) echo "TEST-E-FAIL gtm_autorelink_ctlmax environment variable is overwritten"

chmod u+w mumps.dat	# restore permissions before dbcheck
$gtm_tst/com/dbcheck.csh
