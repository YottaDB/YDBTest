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

# Change in KILL logic to support both M-Standard Kill as well as non-M Standard Kill. The default behavior will be
# non-M standard Kill. gtm_stdxkill/GTM_STDXKILL on UNIX/VMS (respectively) if specified as "1" or "TRUE" or "YES"
# (case insensitive) will indicate whether the default behavior has to be overridden
#

echo "C9J11003211 test starts..."

$echoline
echo "Test 1: ydb_stdxkill/gtm_stdxkill not set in the evironment. Expect PASS"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_stdxkill gtm_stdxkill
$gtm_exe/mumps -r C9J11003211

$echoline
echo "Test 2: ydb_stdxkill/gtm_stdxkill set to 1 (override default Kill behavior) in the environment. Expect PASS"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_stdxkill gtm_stdxkill 1
$gtm_exe/mumps -r C9J11003211

$echoline
echo "Test 3: ydb_stdxkill/gtm_stdxkill set to a bad value - 'BAD'. Expect Invalid Setting via Error trap"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_stdxkill gtm_stdxkill "BAD"
$gtm_exe/mumps -r C9J11003211

echo "C9J11003211 test ends.."
