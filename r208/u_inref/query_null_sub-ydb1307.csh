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
echo '# [YDB#1307] $QUERY() of a local whose last subscript is "" never returns that node itself with      #'
echo '# standard null collation                                                                            #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# With standard null collation, $QUERY(x(...,"")) of a local variable returned x(...,"") itself when'
echo '# that node existed, unless the previous $QUERY() in the process had returned that same reference. So'
echo '# the result of a call depended on the call before it.'
echo '#'
echo '# Stages 1 and 2 fail without the fix. Stage 3 passes without the fix too; it checks that GT.M null'
echo '# collation, where $QUERY(x(...,"")) returns the first node at that level, is unchanged. Each check'
echo '# names the result it expects.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1307.m .
# The checks assume that local subscripts use the default M collation sequence (no ydb_local_collate),
# since an alternative collation sequence would change the order of the nodes. Each stage sets the
# null collation (ydb_lct_stdnull) itself.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate

echo '# Stage 1 : $QUERY() of locals with a trailing null subscript, with standard null collation'
echo '# Command : $gtm_dist/mumps -run stdnull^ydb1307 (with ydb_lct_stdnull=1)'
echo '#   expect the node that follows x(...,""), whatever the previous $QUERY() returned'
echo '#   previously x(...,"") itself when that node existed, unless the previous $QUERY() had returned it'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 1
$gtm_dist/mumps -run stdnull^ydb1307
echo

echo '# Stage 2 : $QUERY() of locals compared with $QUERY() of globals holding the same random trees'
echo '# Command : $gtm_dist/mumps -run random^ydb1307 (with ydb_lct_stdnull=1, and a database with'
echo '#           null subscripts and standard null collation)'
echo '#   expect the same result for a local and a global, for every node and every node with an extra'
echo '#   trailing "" subscript'
echo '#   The fixed seed builds the same 500 trees in every run, each with 1 to 8 nodes up to 3 levels deep.'
echo '#   x(""), every node and every node with an extra trailing "" subscript are checked, which is 4605'
echo '#   references in all.'
echo '#   previously a local returned x(...,"") itself where the global returned the node that follows it'
$gtm_tst/com/dbcreate.csh mumps 1 -stdnull -null_subscripts=TRUE >& dbcreate.out
if ($status) then
	echo "TEST-E-DBCREATE : dbcreate.csh failed. See dbcreate.out"
	cat dbcreate.out
endif
$gtm_dist/mumps -run random^ydb1307
echo

echo '# Stage 3 : $QUERY() of locals with a trailing null subscript, with GT.M null collation'
echo '# Command : $gtm_dist/mumps -run gtmnull^ydb1307 (with ydb_lct_stdnull=0)'
echo '#   expect the first node at that level, the node after a("") right after a $QUERY() that returned'
echo '#   a(""), and a $QUERY() loop to visit every node once'
echo '#   previously the same results, since the fix does not apply to GT.M null collation'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 0
$gtm_dist/mumps -run gtmnull^ydb1307
source $gtm_tst/com/unset_ydb_env_var.csh ydb_lct_stdnull gtm_lct_stdnull
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "TEST-E-DBCHECK : dbcheck.csh failed. See dbcheck.out"
	cat dbcheck.out
endif
echo "# Done"
