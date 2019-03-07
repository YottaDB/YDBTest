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
#
# D9D10-002376 Verify LVNULLSUBS is comprehensively handled
#
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lvnullsubs gtm_lvnullsubs 0
$gtm_dist/mumps -run d002376

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lvnullsubs gtm_lvnullsubs 1
$gtm_dist/mumps -run d002376

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lvnullsubs gtm_lvnullsubs 2
$gtm_dist/mumps -run d002376

source $gtm_tst/com/unset_ydb_env_var.csh ydb_lvnullsubs gtm_lvnullsubs

