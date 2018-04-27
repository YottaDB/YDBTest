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

# EXCEPTION
unset gtm_ztrap_form
$GTM << EOF
do ^except
halt
EOF

# We are testing $ztrap here
if ($?gtm_etrap) then
	set save_gtm_etrap="$gtm_etrap"
endif
unsetenv gtm_etrap

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ztrap_form gtm_ztrap_form code
$GTM << EOF
do ^except
halt
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ztrap_form gtm_ztrap_form adaptive
$GTM << EOF
do ^except
halt
EOF

unset gtm_ztrap_form

if ($?save_gtm_etrap) then
	setenv gtm_etrap "$save_gtm_etrap"
endif
