#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest tests mupip rundown behavior while doing parallel
# GTM updates without gtm_passwd

setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate.csh mumps 1

setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

echo "-----------------------------------------------------------------------------------------------"
echo "Issue mupip rundown while doing GTM updates without gtm_passwd and expect to error out"
echo "-----------------------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip rundown -region DEFAULT"
$MUPIP rundown -region DEFAULT

echo "-----------------------------------------------------------------------------------------------"
echo "Issue mupip rundown while doing GTM updates with bad gtm_passwd and expect to error out"
echo "-----------------------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip rundown -region DEFAULT"
$MUPIP rundown -region DEFAULT
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/reset_gpg_agent.csh
