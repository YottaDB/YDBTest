#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that ydb_tp_s()/ydb_tp_st() returns negative error code for GBLOFLOW error"

echo "# Create database with minimum blocksize (512), allocation (10) and extension (0) to create GBLOFLOW error as soon as possible"
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=512 -allocation=10 -extension_count=0

set file="ydb383.c"
set exefile = $file:r
echo "# Compiling/Linking $file into executable $exefile and executing it"
cp $gtm_tst/$tst/inref/$file .
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "YDB352-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif
rm $exefile.o	# since we will later create ydb383.o from ydb383.m, we remove ydb383.o created here from ydb383.c
echo ""
`pwd`/$exefile
echo "$exefile returned with exit status : $status"
echo ""

$gtm_tst/com/dbcheck.csh
