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
set randint = $$
set randhex = `openssl rand -hex 3`
set randnum = $$

$gtm_tst/com/dbcreate.csh mumps 1 >>& create1.out
echo "Setting Hard Spin Count"
$MUPIP SET -region DEFAULT -HARD_SPIN_COUNT=$randint
#Will only display if Hard Spin Count is correct in DSE Dump
$DSE dump -file |& $grep "Hard Spin Count" |& $grep "$randint"
echo "Setting Spin Sleep Mask"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_MASK=$randhex
#This DSE Dump is looking for the rand hex value in the mask section (not
#taking caps into consideration), if it outputs anything, we know the spin
#sleep mask value is correct (the test environment will filter this value in
#the outref file)
$DSE dump -file |& $grep "mask" |& $grep -i "$randhex"
echo "Attempting to set Spin Sleep Limit"
$MUPIP SET -region DEFAULT -SPIN_SLEEP_LIMIT=$randnum
$gtm_tst/com/dbcheck.csh >>& check1.out


