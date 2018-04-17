#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Check both default prompt and overridden prompt
#
source $gtm_tst/com/unset_ydb_env_var.csh ydb_prompt gtm_prompt
$gtm_dist/mumps -dir << EOF1
halt
EOF1
#
# Now override the prompt with "YDB>"
#
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_prompt gtm_prompt "YDB>"
$gtm_dist/mumps -dir << EOF2
halt
EOF2
#
# Now override the prompt with "GTM>"
#
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_prompt gtm_prompt "GTM>"
$gtm_dist/mumps -dir << EOF2
halt
EOF

