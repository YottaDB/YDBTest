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
echo "# Test Call-in APIs don't know how to handle dollar quit"
echo "# Build ydb737 executable"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb737.c
$gt_ld_linker $gt_ld_option_output ydb737 $gt_ld_options_common ydb737.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& ydb632.map
if (0 != $status) then
    echo "YDB632-E-LINKFAIL : Linking ydb737 failed. See ydb737.map for details"
    continue
endif
echo "# Running ydb737..."
$gtm_tst/com/dbcreate.csh mumps
env ydb_ci=$gtm_tst/$tst/inref/ydb737.ci ./ydb737
