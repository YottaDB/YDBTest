#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1285] Reverse $QUERY() and ydb_node_previous_s() on a local variable return an ancestor that  #'
echo '# has a value but no descendants, when the starting node does not exist                              #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An ancestor of a node collates immediately before it. When the starting node does not exist and an'
echo '# ancestor of it has a value but no descendants, that ancestor is the result. op_fnreversequery.c'
echo '# skipped it, and returned the node before it, or the empty string if there was none.'
echo '#'
echo '# Without the fix, every check below prints WRONG except the controls: $query(x("a",4),-1) and'
echo '# ydb_node_previous_s() once x("a") has a descendant, $query(b(1,2),-1) with only b defined, and the'
echo '# $order() that confirms the collation in stage 3.'
echo

cp $gtm_tst/$tst/inref/ydb1285.m .

echo '# Stage 1 : $QUERY(lvn,-1) with the direction known at compile time'
echo '# Command : $ydb_dist/yottadb -run direct^ydb1285'
echo '#   expect each result to be the ancestor of the starting node that has a value'
$ydb_dist/yottadb -run direct^ydb1285
echo

echo '# Stage 2 : $QUERY(lvn,d) with d=-1, and $QUERY(@ref,-1) and $QUERY(@ref,d)'
echo '# Command : $ydb_dist/yottadb -run runtime^ydb1285'
echo '#   expect the same results as the compile time form'
$ydb_dist/yottadb -run runtime^ydb1285
echo

echo '# Stage 3 : $QUERY(lvn,-1) with a local collation sequence that reverses the order of strings'
echo '# Command : source $gtm_tst/com/cre_coll_sl_reverse.csh 1 ; $ydb_dist/yottadb -run revcoll^ydb1285'
echo '#   expect $order(x("")) to be "b", confirming the collation is in effect, and the ancestor x("a")'
echo '#   rather than x("b","c"), which collates before it'
source $gtm_tst/com/cre_coll_sl_reverse.csh 1 >& cre_coll_sl_reverse.out
$ydb_dist/yottadb -run revcoll^ydb1285
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate
echo

echo '# Stage 4 : ydb_node_previous_s() on a local variable'
echo '# Command : build and run ydb1285_sapi.c'
echo '#   expect the same results as $QUERY(lvn,-1)'
set file = ydb1285_sapi
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
./$file
echo

echo '# Stage 5 : compare $QUERY(lvn,-1) with $QUERY(gvn,-1), which was not affected, over 500 random trees'
echo '#           of up to 8 nodes with up to 3 subscripts, and 50 random starting nodes with up to 4'
echo '#           subscripts in each tree'
echo '# Command : $ydb_dist/yottadb -run random^ydb1285'
echo '#   expect no differences'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
$ydb_dist/yottadb -run random^ydb1285
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo

echo "# Done"
