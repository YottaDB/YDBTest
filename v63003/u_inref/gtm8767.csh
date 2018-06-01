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
#
set randint = `$gtm_tst/com/genrandnumbers.csh 1 0 2147483647`
set randhex = `$ydb_dist/mumps -run ^%XCMD 'write $$FUNC^%DH($random(2**30))'`

$gtm_tst/com/dbcreate.csh mumps 1 >>& create1.out


echo "# Setting Hard Spin Count to 0 using MUPIP SET -HARD_SPIN_COUNT"
$MUPIP SET -region DEFAULT -HARD_SPIN_COUNT=0
echo "# Verifying Hard Spin Count shows up in DSE Dump"
$DSE dump -file |& $grep "Hard Spin Count"


echo "# Setting Hard Spin Count to 2**31-1 using MUPIP SET -HARD_SPIN_COUNT"
$MUPIP SET -region DEFAULT -HARD_SPIN_COUNT=2147483647
echo "# Verifying Hard Spin Count shows up in DSE Dump"
$DSE dump -file |& $grep "Hard Spin Count"

echo "# Setting Hard Spin Count to a random value using MUPIP SET -HARD_SPIN_COUNT"
$MUPIP SET -region DEFAULT -HARD_SPIN_COUNT=$randint
#Will only display if Hard Spin Count is correct in DSE Dump
echo "# Verifying Hard Spin Count shows up in DSE Dump"
$DSE dump -file |& $grep "Hard Spin Count" |& $grep "$randint"

echo "# Attempting to set Hard Spin Count to 2**31 using MUPIP SET -HARD_SPIN_COUNT"
$MUPIP SET -region DEFAULT -HARD_SPIN_COUNT=2147483648



echo "# Setting Spin Sleep Mask to 0 using MUPIP SET -SPIN_SLEEP_MASK"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_MASK=0x00000000
echo "# Verifying Spin Sleep Mask shows up in DSE Dump"
$DSE dump -file |& $grep "mask"|& $grep "0x00000000"

echo "# Setting Spin Sleep Mask to 0x3fffffff using MUPIP SET -SPIN_SLEEP_MASK"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_MASK=0x3fffffff
echo "# Verifying Spin Sleep Mask shows up in DSE Dump"
$DSE dump -file |& $grep "mask" |& $grep -i "0x3fffffff"

echo "# Setting Spin Sleep Mask to a random hex using MUPIP SET -SPIN_SLEEP_MASK"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_MASK=$randhex
#This DSE Dump is looking for the rand hex value in the mask section (not
#taking caps into consideration), if it outputs anything, we know the spin
#sleep mask value is correct (the test environment will filter this value in
#the outref file)
echo "# Verifying Spin Sleep Mask shows up in DSE Dump"
$DSE dump -file |& $grep "mask" |& $grep -i "$randhex"

echo "# Attempting to set Spin Sleep Mask to 0x40000000 using MUPIP SET -SPIN_SLEEP_MASK"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_MASK=0x40000000


echo "# Attempting to set Spin Sleep Limit to a random value using MUPIP SET -SPIN_SLEEP_LIMIT"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_LIMIT=$randint
$gtm_tst/com/dbcheck.csh >>& check1.out
