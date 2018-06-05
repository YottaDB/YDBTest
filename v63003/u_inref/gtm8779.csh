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
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif


echo "# Initially, all regions set to OFF"
set t0 = `date +"%b %e %H:%M:%S"`

echo "# Setting DEFAULT and AREG to OFF, BREG to ON"
$MUPIP FREEZE -OFF DEFAULT
$MUPIP FREEZE -OFF AREG
$MUPIP FREEZE -ON BREG

# Passing a random string into the sys log after we make changes, getoper will
# print everything in the syslog between t0 and the occurence of this random string
$ydb_dist/mumps -run gtm8779 >>& temp0.out
set s0 = `cat temp0.out`
echo "# Verifying System received a DBFREEZEON message for only BREG"
$gtm_tst/com/getoper.csh "$t0" "" t0t1.txt "" $s0
cat t0t1.txt |& $grep DBFREEZE |& $tst_awk '{print $6 " " $7 " " $8 " " $9 " " $10}'


# To ensure our previous freeze settings are not captured in getoper
sleep 1
echo ""


set t1 = `date +"%b %e %H:%M:%S"`
echo "# Turning on Freeze for all"
$MUPIP FREEZE -ON "*" |& sort

# Passing a random string into the sys log after we make changes, getoper will
# print everything in the syslog between t1 and the occurence of this random string
$ydb_dist/mumps -run gtm8779 >>& temp1.out
set s1 = `cat temp1.out`
echo "# Verifying System received a DBFREEZEON message for only DEFAULT and AREG"
$gtm_tst/com/getoper.csh "$t1" "" t1t2.txt "" $s1
cat t1t2.txt |& $grep DBFREEZE |& $tst_awk '{print $6 " " $7 " " $8 " " $9 " " $10}' |& sort


# To ensure our previous freeze settings are not captured in getoper
sleep 1
echo ""


set t2 = `date +"%b %e %H:%M:%S"`
echo "# Resetting DEFAULT and AREG to OFF, BREG to ON"
$MUPIP FREEZE -OFF DEFAULT
$MUPIP FREEZE -OFF AREG
$MUPIP FREEZE -ON BREG

# Passing a random string into the sys log after we make changes, getoper will
# print everything in the syslog between t2 and the occurence of this random string
$ydb_dist/mumps -run gtm8779 >>& temp2.out
set s2 = `cat temp2.out`
echo "# Verifying System received a DBFREEZEOFF message for only AREG and DEFAULT"
$gtm_tst/com/getoper.csh "$t2" "" t2t3.txt "" $s2
cat t2t3.txt |& $grep DBFREEZE |& $tst_awk '{print $6 " " $7 " " $8 " " $9 " " $10}'


# To ensure our previous freeze settings are not captured in getoper
sleep 1
echo ""

set t3 = `date +"%b %e %H:%M:%S"`
echo "# Turning off Freeze for all"
$MUPIP FREEZE -OFF "*" |& sort

# Passing a random string into the sys log after we make changes, getoper will
# print everything in the syslog between t3 and the occurence of this random string
$ydb_dist/mumps -run gtm8779 >>& temp3.out
set s3 = `cat temp3.out`
echo "# Verifying System received a DBFREEZEOFF message for only BREG"
$gtm_tst/com/getoper.csh "$t3" "" t3t4.txt "" $s3
cat t3t4.txt |& $grep DBFREEZE |& $tst_awk '{print $6 " " $7 " " $8 " " $9 " " $10}'

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
