#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# This subtest tests various mupip utilities behavior without gtm_passwd
# 1. endiancvt ( Requied gtm_passwd )
# 2. mupip extend ( Not required gtm_passwd)
# 3. mupip integ (Requires gtm_passwd)
# 4. mupip reorg (Required gtm_passwd)

setenv save_gtm_passwd $gtm_passwd
setenv gtmgbldir mumps
$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

echo "----------------------------------------------------------------------------------"
echo "endian convert with out gtm_passwd and expect error out"
echo "----------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip endianevt mumps.dat"
$MUPIP endiancvt mumps.dat

echo "----------------------------------------------------------------------------------"
echo "endian convert with bad gtm_passwd and expect error out"
echo "----------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip endianevt mumps.dat"
$MUPIP endiancvt mumps.dat

echo "----------------------------------------------------------------------------------"
echo "mupip extend with bad gtm_passwd and expect to work without any error"
echo "----------------------------------------------------------------------------------"
echo "mupip extend DEFAULT -blocks=1000"
$MUPIP extend DEFAULT -blocks=1000

echo "----------------------------------------------------------------------------------"
echo "Integ without gtm_passwd and expect to error out"
echo "----------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat

echo "----------------------------------------------------------------------------------"
echo "Integ with bad gtm_passwd and expect to error out"
echo "----------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat

echo "----------------------------------------------------------------------------------"
echo "Integ with correct password and expect to work"
echo "----------------------------------------------------------------------------------"
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat

echo "----------------------------------------------------------------------------------"
echo "mupip reorg without gtm_passwd and expect to error out"
echo "----------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
# Set white box test case to avoid asserts in dsk_read to failed encryption initialization
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
echo "mupip reorg -region DEFAULT"
$MUPIP reorg -region DEFAULT

echo "----------------------------------------------------------------------------------"
echo "mupip reorg with bad gtm_passwd and expect to error out"
echo "----------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip reorg -region DEFAULT"
$MUPIP reorg -region DEFAULT

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/dbcheck.csh
