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
#
echo "# Test that interrupted and resumed TP callback routine does not hang if it drives ydb_exit()"
#
echo "# Build ydb632 executable"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb632.c
$gt_ld_linker $gt_ld_option_output ydb632 $gt_ld_options_common ydb632.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& ydb632.map
if (0 != $status) then
    echo "YDB632-E-LINKFAIL : Linking ydb632 failed. See ydb632.map for details"
    continue
endif
echo "# Running ydb632.."
$gtm_tst/com/dbcreate.csh mumps
`pwd`/ydb632
# Rename the core file we find so the framework does not find it
set f=`ls -1 core.*`
mv -- "$f" "save${f}"
# Check DBs
$gtm_tst/com/dbcheck.csh
