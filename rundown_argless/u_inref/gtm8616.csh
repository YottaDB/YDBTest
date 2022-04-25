#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
set t = `date +"%b %e %H:%M:%S"`
sleep 1
# Using .outx because expecting a warning about an argumentless MUPIP RUNDOWN
echo "# Running argumentless MUPIP RUNDOWN and checking syslog"
echo ""
($MUPIP RUNDOWN&; echo $! >&! pid.txt)>&rundown.outx
set pid=`cat pid.txt`
$gtm_tst/com/wait_for_proc_to_die.csh $pid
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
# It is possible getoper.txt contains MURNDWNARGLESS messages from other concurrently running tests too.
# Therefore filter out the messages corresponding to this particular test run using `pwd` (the test output directory
# which is unique to each test) below. Note that we dont use $cwd as it does not expand soft links whereas `pwd` does.
mv getoper.txt getoper.txt.orig
grep `pwd` getoper.txt.orig > getoper.txt
echo "# Syslog message:"
$grep "process id" getoper.txt |& sed 's/.*%YDB-I-MURNDWNARGLESS/%YDB-I-MURNDWNARGLESS/'
set getoperpid=`$grep "process id" getoper.txt |& $tst_awk '{print $14}'`
set getoperuid=`$grep "process id" getoper.txt |& $tst_awk '{print $17}'`
if ($uid == $getoperuid) then
	echo "# User ID in syslog message correct"
else
	echo "# Incorrect User ID in syslog message, expected $uid but found $getoperuid"
endif
if ($pid == $getoperpid) then
	echo "# PID in syslog message correct"
else
	echo "# Incorrect PID in syslog message, expected $pid but found $getoperpid"
endif
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
