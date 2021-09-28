#!/usr/local/bin/tcsh -f
#################################################################
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
#
echo "# Test ydb_lock_incr_s() call in child process while parent process holds the lock."
echo "# This used to assert fail in op_lock2.c previously."
#
set file = "ydb782"
echo "# Build $file executable"

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
if (0 != $status) then
	echo "TEST-E-LINKFAIL : Linking $file failed. See $file.map for details"
	exit 1
endif
echo "# Create database using dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps
echo "# Running $file executable"
`pwd`/$file
if (0 != $status) then
	echo "TEST-E-RUNFAIL : Running $file failed"
	exit 1
endif
echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh
