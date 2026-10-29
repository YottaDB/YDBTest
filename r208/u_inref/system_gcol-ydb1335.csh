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
echo '# [YDB#1335] $SYSTEM does not hold garbage after SET $SYSTEM once the string pool has been expanded  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# SET $SYSTEM to a non-empty value sets $SYSTEM to its initial value followed by the new value, and'
echo '# SET $SYSTEM to the empty string sets $SYSTEM back to the initial value. The initial value is kept in'
echo '# the string pool, but the string pool garbage collector did not update the copy of the initial value'
echo '# that SET $SYSTEM uses, so after a garbage collection that moved strings or expanded the string pool,'
echo '# SET $SYSTEM used freed or reused memory in place of the initial value.'
echo '#'
echo '# Each stage uses enough string space (long local variable values) to expand the string pool, then'
echo '# does a SET $SYSTEM and checks the new value of $SYSTEM. So that the memory freed when the string'
echo '# pool is expanded no longer holds the initial value, the stages use the system memory allocator'
echo '# (gtmdbglvl=0x80000000) and have glibc fill freed memory (MALLOC_PERTURB_=170).'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1335.m .

# The test system sets gtmdbglvl at random. Use the setting this subtest needs.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_dbglvl gtmdbglvl
setenv gtmdbglvl 0x80000000
setenv MALLOC_PERTURB_ 170
echo '# Command : setenv gtmdbglvl 0x80000000'
echo '# Command : setenv MALLOC_PERTURB_ 170'
echo

echo '# Stage 1 : the example in YDB#1335: expand the string pool, then SET $SYSTEM="abc"'
echo '# Before the fix : $SYSTEM had garbage in place of the initial value, followed by abc (an ASAN build'
echo '#                  reported a heap-use-after-free in op_svput())'
echo '# With the fix   : expect $SYSTEM to be the initial value followed by abc'
echo '# Command : $gtm_dist/mumps -run append^ydb1335'
$gtm_dist/mumps -run append^ydb1335
echo

echo '# Stage 2 : SET $SYSTEM="xyz", expand the string pool, then SET $SYSTEM="" to get back the initial'
echo '#           value'
echo '# Before the fix : $SYSTEM was garbage in place of the initial value'
echo '# With the fix   : expect $SYSTEM to be the initial value'
echo '# Command : $gtm_dist/mumps -run reset^ydb1335'
$gtm_dist/mumps -run reset^ydb1335
echo

echo "# Done"
