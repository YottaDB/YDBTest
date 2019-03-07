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
# This module is derived from FIS GT.M.
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1
#
# Run 1
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_side_effects gtm_side_effects 0
setenv gtm_boolean 0
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.1
# Run 2
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_side_effects gtm_side_effects 0
setenv gtm_boolean 1
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.2
# Run 3
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_side_effects gtm_side_effects 1
setenv gtm_boolean 0
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.3
# Run 4
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_side_effects gtm_side_effects 1
setenv gtm_boolean 1
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.4
#
echo ""
$gtm_tst/com/dbcheck.csh
