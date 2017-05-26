#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv tst_buffsize  1048576
set gtm_process = 2
#
$gtm_tst/com/dbcreate.csh mumps 9 255 1000 -allocation=2048 -extension_count=2048
setenv start_time `cat start_time`
setenv test_sleep_sec 60
# GTM Process starts
$gtm_tst/com/imptp.csh $gtm_process >&! imptp.out
sleep $test_sleep_sec
$pri_shell "cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip"
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default.
echo '$gtm_tst/com/mupip_rollback.csh -backward -resync=1 -losttrans=lost1.glo *'
$gtm_tst/com/mupip_rollback.csh -backward -resync=1 -losttrans=lost1.glo "*"
echo 'Secondary Side: $gtm_tst/com/mupip_rollback.csh -backward -losttrans=lost2.glo *'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -backward -losttrans=lost2.glo "*"'
echo "$MUPIP journal -recover -back *"
$MUPIP journal -recover -back "*"
$gtm_tst/com/endtp.csh >>&! imptp.out
\cat *.mje*
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
