#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : S9908-001327 Update process died on receiving TRETRY signal
#
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 2048 512 500
setenv start_time `cat start_time`
if (! $?helper_rand) then
	@ helper_rand = `$gtm_exe/mumps -run rand 100 1 1`
endif
echo "setenv helper_rand $helper_rand" >>! settings.csh
if ($helper_rand > 50) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP  replicate -receive -start -helpers >& helpers_start.out"
endif
#
echo "GTM Process starts in background..."
setenv gtm_test_jobcnt 5
setenv gtm_test_dbfill "IMPTP"
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_sec_short
#
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/var_tp_rest.csh >>&! var_tp_rest.out"
echo "Now GTM process will end."
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
