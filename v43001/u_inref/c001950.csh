#!/usr/local/bin/tcsh -f
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

unsetenv gtmprincipal
source $gtm_tst/com/unset_ydb_env_var.csh ydb_principal gtm_principal

setenv gtmprincipal	"abcdefgh"
$GTM << GTM_EOF
w \$p,!
GTM_EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_principal gtm_principal "ijklmnop"
$GTM << GTM_EOF
w \$p,!
GTM_EOF

