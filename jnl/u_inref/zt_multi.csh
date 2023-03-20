#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test was originally written to test ZTP but with V63002, this fails asserts.
# Since ZTP is no longer supported, this test is now changed to use TP (instead of ZTP).
#
# Below is original comment
#	C9C01-001878 GTM fails for multi-process journaling test with ZTS/ZTC
#	Subtest makes sense only when run with TP as it tests some features of ZTP/ZTC.
#
if ($gtm_test_tp == "NON_TP") then
	echo "zt_multi must be executed in TP mode."
	exit 1
endif
$gtm_tst/com/dbcreate.csh mumps 4 125 1000
if (0 == $?test_replic) then
        $MUPIP set -journal=enable,on,before -reg "*" |& sort -f
endif
echo "GTM Processes will start now"
setenv gtm_test_jobcnt 4
setenv gtm_test_dbfill "IMPTP"
$gtm_tst/com/imptp.csh >&! multi_tp.out
source $gtm_tst/com/imptp_check_error.csh multi_tp.out; if ($status) exit 1
sleep 60
echo "GTM Processes will end"
$gtm_tst/com/endtp.csh >>&! endtp.out
echo "All GTM Processes exited"
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
echo "$MUPIP journal -recover -back * -since=0 0:0:50"
$MUPIP journal -recover -back "*" -since=\"0 0:0:50\" >& recover.log
# The FILERENAME messages could show up out-of-order due to ftok differences in *.dat files so sort them before displaying
$grep FILERENAME recover.log |& sort -f
$grep -v FILERENAME recover.log
