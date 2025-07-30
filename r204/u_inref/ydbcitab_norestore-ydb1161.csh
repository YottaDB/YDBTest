#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test that %YDB-E-CITABENV error is not issued when calling an M function via a function handle returned by a previous call to ydb_cip_t'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

echo 'ydb1161: int* run^ydb1161()' >& table1.ci

echo "run() quit 1" > ydb1161.m

set file = ydb1161-ci
echo "# Build a C program [ydb1161.c] to test that a %YDB-E-CITABENV error is not issued when reusing a call-in function:"
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
echo

echo "# Run the compiled [ydb1161.c] program:"
$PWD/$file
