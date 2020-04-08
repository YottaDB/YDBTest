#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that a nested ydb_tp_st() rolls back correctly when the parent transaction commits'
echo '# We also run a version of the test for 10 seconds with multiple threads without output to ensure that YDB_TP_RESTART is handled correctly'

foreach file ("ydb550" "ydb550b")
	#SETUP of the driver C file
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
	$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map

	$gtm_tst/com/dbcreate.csh mumps

	# Run driver C
	`pwd`/$file

echo "start Thread 1"
cat thread1.out
echo "end Thread 1\n"
echo "start Thread 2"
cat thread2.out
echo "end Thread 2\n"
echo "start Thread 3"
cat thread3.out
echo "end Thread 3\n"
echo "start Thread 4"
cat thread4.out
echo "end Thread 4"

$gtm_tst/com/dbcheck.csh
