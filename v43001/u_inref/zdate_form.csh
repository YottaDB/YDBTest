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

# zdate: C9C02-001928 Provide a means of formatting 21st century as 4 digits as default
echo "Entering ZDATE_FORM subtest"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_zdate_form gtm_zdate_form
$gtm_exe/mumps -run zdform
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zdate_form gtm_zdate_form 1
$gtm_exe/mumps -run zdform
source $gtm_tst/com/unset_ydb_env_var.csh ydb_zdate_form gtm_zdate_form
echo "Leaving ZDATE_FORM subtest"
