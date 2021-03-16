#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

# This tests that MUPIP LOAD supports loading records larger than 2**32 up to a maximum of 2**64 in all
# three modes (bin, go and zwr). Portions of this test were copied from the v51000/D9G01002592 test

# 'go' format is not supported in UTF-8 mode
# Since the intent of the subtest is explicitly check all three formats, it is forced to run in M mode
$switch_chset M >&! switch_chset.out
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512	# keysize=255, recsize=480, blksize=512
cat >> gtm9206.m << xx
	set ^y(1)=\$justify(1,5)
	for i=1:1:10 set ^x(i)=\$justify(i,400)
	halt
xx
$ydb_dist/mumps -r gtm9206

foreach fmt (zwr go bin)
	echo ""
	echo "######################################################################################"
	echo "                           Testing format=$fmt"
	echo "######################################################################################"
	set verbose
	$MUPIP extract -format=$fmt all.$fmt
	if ($fmt == bin) then
		set fmtstr = "-format=bin"
	else
		set fmtstr = ""	# test that no -format specification assumes -fmt=zwr or -fmt=go and figures the right one
	endif
	$echoline
	$MUPIP load $fmtstr -begin=4294967294 -end=4294967298 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4294967296 -end=4294967300 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4294967300         all.$fmt	# without any -end qualifier
	$echoline
	$MUPIP load $fmtstr          -end=4294967300 all.$fmt	# without any -begin qualifier
	$echoline
	$MUPIP load $fmtstr -begin=5000000000 -end=5000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=6000000000 -end=6000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=7000000000 -end=7000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=8000000000 -end=8000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=9000000000 -end=9000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=10000000000 -end=10000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=50000000000 -end=50000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=100000000000 -end=100000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=500000000000 -end=500000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=1000000000000 -end=1000000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=12500000000000000000 -end=12500000000000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=14000000000000000000 -end=14000000000000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=15500000000000000000 -end=15500000000000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=17000000000000000000 -end=17000000000000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=18446744073709551615 -end=18446744073709551615 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=18446744073709551615 -end=18446744073709551616 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=18446744073709551616 -end=18446744073709551615 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=18446744073709551616 -end=18446744073709551616 all.$fmt
	unset verbose
end
$gtm_tst/com/dbcheck.csh
