# system: C9B12-001868 $SYSTEM setup does not work as advertised
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

echo "Entering SYSTEM_ISV subtest"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_sysid gtm_sysid
$gtm_exe/mumps -run dsystem
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_sysid gtm_sysid foobar
$gtm_exe/mumps -run dsystem
source $gtm_tst/com/unset_ydb_env_var.csh ydb_sysid gtm_sysid
echo "Leaving SYSTEM_ISV subtest"
