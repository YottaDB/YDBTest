#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that transid specified in ydb_tp_s() does go into journal file
#

echo "# Enable journaling in test"
setenv gtm_test_jnl "SETJNL"

$gtm_tst/com/dbcreate.csh mumps 1

set file = "transid.c"
cp $gtm_tst/$tst/inref/$file .

echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "GVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	continue
endif
`pwd`/$exefile
echo ""

echo "# Extract journal files and dump transid in TCOM record"
$gtm_tst/com/jnlextall.csh mumps >& jnlextall.out
if ($status) then
	echo "JNLEXTALL-E-FAIL : See jnlextall.out for details"
endif
$tst_awk -F\\ '/TCOM/ {print $11;}' mumps.mjf | sed 's/^/TCOM : transid=/g'

$gtm_tst/com/dbcheck.csh
