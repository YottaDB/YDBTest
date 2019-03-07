#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that ydb_ci() call with an error after a ydb_set_s()/ydb_set_st() of a spanning node does not GTMASSERT2"

$gtm_tst/com/dbcreate.csh mumps 1 -block_size=512 -record_size=1024

echo "# Setting up ydb352.xc and ydb_ci env var to point to it"
cat > ydb352.xc << CAT_EOF
ydb352: void ydb352()
CAT_EOF

setenv ydb_ci ydb352.xc	# needed to invoke ydb352.m from ydb352.c below

set file="ydb352.c"
set exefile = $file:r
echo "# Compiling/Linking $file into executable $exefile and executing it"
cp $gtm_tst/$tst/inref/$file .
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "YDB352-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif
rm $exefile.o	# since we will later create ydb352.o from ydb352.m, we remove ydb352.o created here from ydb352.c
`pwd`/$exefile
echo "$exefile returned with exit status : $status"

$gtm_tst/com/dbcheck.csh
