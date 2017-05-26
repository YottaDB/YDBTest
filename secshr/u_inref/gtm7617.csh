#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# please refer to test/secshr/inref_u/gtm7617.m for test purpose

$gtm_tst/com/dbcreate.csh mumps 1
# Some nonsense in here for the timestamps used by getoper. Because
# gtmsecshr_wrapper unsets the timezone setting, we need to tell getoper to
# search for timestamps until the UTC end time. Hence 'date -u' for the end
# time, but a straight 'date' for the starting time.
set ts1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run gtm7617
# force time to advance by one second
sleep 1
set ts2 = `date -u +"%b %e %H:%M:%S"`
echo "ts1=$ts1\tts2=$ts2" > testtimes
$gtm_tst/com/getoper.csh "$ts1" "$ts2" initfailmessages.txt '' "GTMSECSHRINIT" 3
$gtm_exe/mumps -run validate^gtm7617 initfailmessages.txt
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
