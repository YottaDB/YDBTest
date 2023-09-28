#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# [GTM-358] Database key size greater than 255
# Disable V6 mode DB as it creates lots of differences in MUPIP INTEG and DSE DUMP output
setenv gtm_test_use_V6_DBs 0
# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
$gtm_tst/com/dbcreate.csh mumps 1 1019 1500 2048

$DSE dump -fileheader |& $grep "Block size"
$DSE dump -fileheader |& $grep "Maximum record size"
$DSE dump -fileheader |& $grep "Maximum key size"

echo "#######################################################"
echo "# Perform some simple operations with large keys"
$gtm_dist/mumps -run gtm358 >&! simple.out
$MUPIP integ -region DEFAULT
cat simple.out

echo "#######################################################"
echo "# Test DSE functionality"
# find ^d($j(1014,1014))
$DSE << EOF
find -key="^d(""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  1014"")"
EOF
# Note that we TEST_AWK the block tn, the rec_hdr rsiz (to account for both endians), and the unused filler byte.
$DSE dump -block=2A

echo "#######################################################"
echo "# Test various errors that should show up"
echo "# 1. Get some GVSUBOFLOW messages"
$gtm_dist/mumps -run error1^gtm358 >&! error1.txt
$gtm_dist/mumps -run error2^gtm358 >&! error2.txt
echo "# 2. Get some integ errors"
$MUPIP integ -region DEFAULT >&! errorinteg.txt
$grep "No errors detected by integ" errorinteg.txt
$DSE change -fileheader -key=1022
$MUPIP integ -region DEFAULT >&! error3.txt
$gtm_tst/com/check_error_exist.csh error1.txt "GVSUBOFLOW" >&! /dev/null
$gtm_tst/com/check_error_exist.csh error2.txt "GVSUBOFLOW" >&! /dev/null
$gtm_tst/com/check_error_exist.csh error3.txt "DBGTDBMAX" >&! /dev/null

echo "#######################################################"
echo "# Test MUPIP SET -KEY_SIZE and -RECORD_SIZE"
$DSE change -fileheader -key=255
$DSE change -fileheader -rec=100
$DSE dump -fileheader |& $grep "Block size"
$DSE dump -fileheader |& $grep "Maximum record size"
$DSE dump -fileheader |& $grep "Maximum key size"
$MUPIP set -region DEFAULT -key_size=1019
$MUPIP set -region DEFAULT -key_size=1018
$MUPIP set -region DEFAULT -key_size=1024
$MUPIP set -region DEFAULT -record_size=1500
$DSE dump -fileheader |& $grep "Block size"
$DSE dump -fileheader |& $grep "Maximum record size"
$DSE dump -fileheader |& $grep "Maximum key size"

echo "#######################################################"
echo "# Test MUPIP EXTRACT and LOAD"

$gtm_dist/mumps -run '%XCMD' 'zwrite ^x' >&! zwrite1.out

echo "### -format=zwr ###"
$MUPIP extract extr1.zwr
echo "### -format=bin ###"
$MUPIP extract extr2.bin -format=bin
\cp mumps.dat mumps.dat_copy
\rm mumps.dat
$MUPIP create
$MUPIP load extr2.bin -format=bin

$gtm_dist/mumps -run '%XCMD' 'zwrite ^x' >&! zwrite2.out
diff zwrite1.out zwrite2.out

$gtm_tst/com/dbcheck.csh

