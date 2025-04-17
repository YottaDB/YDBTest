#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_encode_s(), ydb_decode_s(), ydb_encode_st(), and ydb_decode_st() in the SimpleAPI/SimpleThreadAPI
#
echo "Copy all C programs that need to be tested"
cp $gtm_tst/$tst/inref/ydb474* .

echo "# Create database"
# Create database with a big enough key and record size since ydb474_st.c needs that
$gtm_tst/com/dbcreate.csh mumps -key_size=1019 -record_size=2048 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

echo ""
echo "Test both the SimpleAPI and SimpleThreadAPI versions of encode and decode"

foreach file (ydb474*.c)
	echo " --> Running $file <---"
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs -ljansson >& $exefile.map
	if (0 != $status) then
		echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		continue
	endif
	`pwd`/$exefile
	echo " --> Finished $file <---"
	echo ""
end

echo "# Check database"
$gtm_tst/com/dbcheck.csh >>& dbcreate.out
