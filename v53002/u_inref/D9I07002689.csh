#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#
# D9I07-002689 test of $ZQUIT (anyway) compilation
#
$gtm_tst/com/dbcreate.csh mumps 1
echo "# try funky QUIT compile; setenv ydb_zquit_anyway/gtm_zquit_anyway 1"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zquit_anyway gtm_zquit_anyway 1
echo "# Compile D9I07002689.m"
$gtm_exe/mumps $gtm_tst/$tst/inref/D9I07002689.m
echo "# run D9I07002689"
$gtm_exe/mumps -run D9I07002689
\rm D9I07002689.o

echo "# verify normal (error) QUIT behavior; unsetenv ydb_zquit_anyway/gtm_zquit_anyway"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_zquit_anyway gtm_zquit_anyway
echo "# Compile D9I07002689.m"
$gtm_exe/mumps $gtm_tst/$tst/inref/D9I07002689.m
echo "# run D9I07002689"
$gtm_exe/mumps -run D9I07002689
echo "# End of test"
$gtm_tst/com/dbcheck.csh
