#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "---------------------------------------------------------------------------"
echo "# Test that terminal settings are reset after exiting a ydb_ci() process"
echo "---------------------------------------------------------------------------"

echo "# Setting up ydb184.xc and ydb_ci env var to point to it"
cat > ydb184.xc << CAT_EOF
ydb184: void ydb184()
CAT_EOF

setenv ydb_ci ydb184.xc # needed to invoke ydb184.m from ydb184.c below

set file="ydb184.c"
set exefile = $file:r
echo "# Compiling/Linking $file into executable $exefile and executing it"
cp $gtm_tst/$tst/inref/$file .
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "YDB184-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif
rm $exefile.o

# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/ydb184.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx       # move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx

