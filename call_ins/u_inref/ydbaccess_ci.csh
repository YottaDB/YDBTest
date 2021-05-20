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
echo "# Run ProgrammersGuide/extrout.html ydbaccess_ci example"
echo "# Build ydbaccess_ci executable"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydbaccess_ci.c
$gt_ld_linker $gt_ld_option_output ydbaccess_ci $gt_ld_options_common ydbaccess_ci.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& ydbaccess_ci.map
if (0 != $status) then
    echo "YDB-E-LINKFAIL : Linking ydbaccess_ci failed. See ydbaccess_ci.map for details"
    continue
endif
echo "# Running ydbaccess_ci..."
$gtm_tst/com/dbcreate.csh mumps
cp $gtm_tst/$tst/inref/ydbaccess.ci .
setenv ydb_dist "$gtm_dist"
setenv ydb_gbldir "$gtmgbldir"
setenv ydb_routines "$gtmroutines"
./ydbaccess_ci
