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

$gtm_tst/com/dbcreate.csh mumps 1

# Let's create a need for gtmsecshr, i.e., read only database file
chmod a-w mumps.dat

echo ""
echo "# Prevent EXEC of gtmsecshr"

$gtm_com/IGS $gtm_dist/gtmsecshr "STOP"	# Make sure secshr not running

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 108

set syslog_time1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/mumps -direct << EOF
write ^a
halt
EOF

chmod a+w mumps.dat

set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" msgs.txt "" "Unable to start gtmsecshr executable"
$grep "Unable to start gtmsecshr executable" msgs.txt >& grepmsgs.txt
if (! $status ) then
	echo "Message Found!"
else
	echo "Message Not Found!"
endif

$gtm_tst/com/dbcheck.csh
