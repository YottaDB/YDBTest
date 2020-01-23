#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
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
# C9B04-001673 provide option to not skip $I(), $$ or $& in boolean expressions because they have side-effects
#
$gtm_tst/com/dbcreate.csh mumps

# Before test starts, unsetenv env vars that would otherwise influence/subvert the intention of this test
source $gtm_tst/com/unset_ydb_env_var.csh ydb_boolean gtm_boolean
source $gtm_tst/com/unset_ydb_env_var.csh ydb_side_effects gtm_side_effects

$gtm_dist/mumps -run C9B04001673
echo " "
setenv save_boolean 0
if ($?gtm_boolean) then
  setenv save_boolean $gtm_boolean
endif
setenv gtm_boolean 2
$gtm_dist/mumps -run C9B04001673d
setenv gtm_boolean 1
$gtm_dist/mumps -run C9B04001673d
unsetenv gtm_boolean
$gtm_dist/mumps -run C9B04001673d
echo " "
setenv gtm_boolean $save_boolean
unsetenv save_boolean
$gtm_tst/com/dbcheck.csh
