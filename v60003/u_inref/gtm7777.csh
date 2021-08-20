#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -file mumps.dat -flush_time=1:0:0:0 # Prevent interruptions from flush timers

echo "# Initialize some data"
$gtm_exe/mumps -run %XCMD 'set (^x,^y)=0'
$MUPIP rundown -reg DEFAULT

echo "# Case 1: *no* intervening update between DBFLUSH and EPOCH"
$gtm_exe/mumps -run case1^gtm7777 >&! case1.log
$gtm_exe/mumps -run expout1^gtm7777 >&! expected_output1.log
diff expected_output1.log case1.log

echo "# Case 2: *yes*, intervening update between DBFLUSH and EPOCH"
$gtm_exe/mumps -run case2^gtm7777 >&! case2.log
$gtm_exe/mumps -run expout2^gtm7777 >&! expected_output2.log
diff expected_output2.log case2.log

$gtm_tst/com/dbcheck.csh
