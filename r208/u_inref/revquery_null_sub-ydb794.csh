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
echo '# [YDB#794] Reverse $QUERY() of a global whose last subscript is "" and that has no value returns    #'
echo '# the last node at that level with standard null collation                                           #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# With standard null collation, $QUERY(^x(...,""),-1) returned the node before ^x(...,"") in'
echo '# collation order, which is ^x(...) or a node before it, as "" collates before all other subscripts.'
echo '# $QUERY(x(...,""),-1) of a local returned the last node at that level. Now a global returns the last'
echo '# node at that level too, when ^x(...,"") has no value. When it has a value, or when the previous'
echo '# $QUERY() returned it, it is looked up as is, so a reverse $QUERY() loop that returned it moves on to'
echo '# the node before it, even if the loop killed it.'
echo '#'
echo '# Without the fix, stages 1, 2 and 3 print WRONG. Stages 4 and 5 pass without the fix too; they check'
echo '# that locals and GT.M null collation are unchanged. Each check names the result it expects.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb794.m .
# The checks assume that local subscripts use the default M collation sequence (no ydb_local_collate),
# since an alternative collation sequence would change the order of the nodes, and that locals use
# standard null collation (ydb_lct_stdnull=1).
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 1
# The global directory below maps ^s across two regions itself, so do not let dbcreate.csh add random mappings
setenv gtm_test_spanreg 0

echo '# Create a database with these GDE commands. ^x is in DEFAULT, ^a in AREG, which has null subscripts'
echo '# disabled, ^c in CREG, which has GT.M null collation, and ^s spans DEFAULT and BREG.'
cat > ydb794.gde << CAT_EOF
template -region -stdnullcoll -null_subscripts=TRUE
change -region DEFAULT -stdnullcoll -null_subscripts=TRUE
change -segment DEFAULT -file=mumps.dat
add -segment ASEG -file=a.dat
add -region AREG -dyn=ASEG -null_subscripts=FALSE
add -name a -region=AREG
add -segment BSEG -file=b.dat
add -region BREG -dyn=BSEG
add -name s(1:"b") -region=BREG
add -segment CSEG -file=c.dat
add -region CREG -dyn=CSEG -nostdnullcoll
add -name c -region=CREG
CAT_EOF
cat ydb794.gde
setenv test_specific_gde `pwd`/ydb794.gde
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
unsetenv test_specific_gde
echo '# Command : $ydb_dist/yottadb -run setup^ydb794'
echo '#   expect each global in the region named above, and each region to have the settings named above'
$ydb_dist/yottadb -run setup^ydb794
echo

echo '# Stage 1 : $QUERY(gvn,-1) of globals with a trailing null subscript'
echo '# Command : $ydb_dist/yottadb -run globals^ydb794'
echo '#   expect the last node at that level when ^x(...,"") has no value, and ^x(...,"") looked up as is'
echo '#   when it has a value or when the previous $QUERY() returned it'
echo '#   previously the node before ^x(...,"") in all cases'
$ydb_dist/yottadb -run globals^ydb794
echo

echo '# Stage 2 : ydb_node_previous_s() of a global with a trailing null subscript'
echo '# Command : build and run ydb794_sapi.c'
echo '#   expect the same results as $QUERY(gvn,-1)'
echo '#   previously the node before ^x(...,"")'
set file = ydb794_sapi
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
./$file
echo

echo '# Stage 3 : compare $QUERY(lvn,-1) with $QUERY(gvn,-1) over 500 random trees in ^x, and 500 in ^s,'
echo '#           which spans regions, of up to 8 nodes with up to 3 subscripts each, for every node and'
echo '#           every node with an extra trailing "" subscript, other than a reference whose trailing ""'
echo '#           node has a value'
echo '# Command : $ydb_dist/yottadb -run random^ydb794'
echo '#   expect no differences. Before each pair of calls, a $QUERY() of another local and of a global'
echo '#   that does not exist clears the previous results that $QUERY() saves, so that each call is a'
echo '#   first call.'
echo '#   The fixed seed builds the same trees in every run, so there are 8631 such references in every run.'
echo '#   previously the global returned the node before ^x(...,"") where the local returned the last node'
echo '#   at that level'
$ydb_dist/yottadb -run random^ydb794
echo

echo '# Stage 4 : $QUERY(lvn,-1) of locals with a trailing null subscript'
echo '# Command : $ydb_dist/yottadb -run locals^ydb794'
echo '#   expect the last node at that level when x(...,"") has no value. When x("") has a value, the first'
echo '#   call returns the last node, and a call right after a $QUERY() that returned x("") returns the'
echo '#   node before it.'
echo '#   previously the same results, since the fix does not change locals'
$ydb_dist/yottadb -run locals^ydb794
echo

echo '# Stage 5 : $QUERY(gvn,-1) of a global with GT.M null collation'
echo '# Command : $ydb_dist/yottadb -run gtmnull^ydb794'
echo '#   expect the last node at that level, and a reverse $QUERY() loop to visit every node once'
echo '#   previously the same results, since the fix does not apply to GT.M null collation'
$ydb_dist/yottadb -run gtmnull^ydb794
echo

source $gtm_tst/com/unset_ydb_env_var.csh ydb_lct_stdnull gtm_lct_stdnull
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
