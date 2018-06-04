#!/usr/local/bin/tcsh -f
#################################################################
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
#
# Testing for DBFREEZEON/DBFREEZEOFF message when freeze state is changed
#

$gtm_tst/com/dbcreate.csh mumps 3 >>& create.out

echo "# Initially, DEFAULT and AREG are OFF, BREG is ON"
$MUPIP FREEZE -OFF DEFAULT >>& init1.out
$MUPIP FREEZE -OFF AREG >>& init2.out
$MUPIP FREEZE -ON BREG >>& init3.out

# To ensure our inital settings are not captured in getoper
sleep 1

set t1 = `date +"%b %e %H:%M:%S"`
echo "# Turning on Freeze for all"
$MUPIP FREEZE -ON "*"

# Passing a random string into the sys log after we make changes, getoper will
# print everything in the syslog between t1 and the occurence of this random string
$ydb_dist/mumps -run gtm8779 >>& temp1.out
set s1 = `cat temp1.out`
echo "# Verifying System received a DBFREEZEON message for only DEFAULT and AREG"
$gtm_tst/com/getoper.csh "$t1" "" t1t2.txt "" $s1
cat t1t2.txt |& $grep DBFREEZE |& $tst_awk '{print $6 " " $7 " " $8 " " $9 " " $10}'

# To ensure difference in start times
sleep 1

echo "# Resetting to initial state"
$MUPIP FREEZE -OFF DEFAULT >>& init4.out
$MUPIP FREEZE -OFF AREG >>& init5.out
$MUPIP FREEZE -ON BREG >>& init6.out

# To ensure our initial settings are not captured in getoper
sleep 1
echo ""

set t2 = `date +"%b %e %H:%M:%S"`
echo "# Turning off Freeze for all"
$MUPIP FREEZE -OFF "*"

# Passing a random string into the sys log after we make changes, getoper will
# print everything in the syslog between t2 and the occurence of this random string
$ydb_dist/mumps -run gtm8779 >>& temp2.out
set s2 = `cat temp2.out`
echo "# Verifying System received a DBFREEZEOFF message for only BREG"
$gtm_tst/com/getoper.csh "$t2" "" t2t3.txt "" $s2
cat t2t3.txt |& $grep DBFREEZE |& $tst_awk '{print $6 " " $7 " " $8 " " $9 " " $10}'

$gtm_tst/com/dbcheck.csh >>& check.out
