#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
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
#
echo "--------------------------------------------------------------"
echo "Test case for mupip rollback"
echo "--------------------------------------------------------------"
source $gtm_tst/com/gtm_test_setbeforeimage.csh
setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate.csh mumps

setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 2

echo "# Start some updates on background process"
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 5		# To allow some data to be set for all regions

echo "# Stop the background process"
$gtm_tst/com/endtp.csh  >>& endtp1.out

#echo "Try Journal DISABLED:"

$MUPIP set -journal=disable -reg "*" |& sort -f

$tst_tcsh $gtm_tst/com/RF_SHUT.csh "on"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base.csh"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcheck_base.csh"

$gtm_tst/com/checkdb.csh

echo "# No background processes are running"
echo "--------------------------------------------------------------"
echo "Mupip rollback without gtm_passwd and expect to error out"
echo "--------------------------------------------------------------"
echo "mupip_rollback.csh -backward -forward -resync=1 -lost=lost.glo *"
unsetenv gtm_passwd
$gtm_tst/com/mupip_rollback.csh -backward -forward -resync=1 -lost=lost.glo "*"
if ($status) then
	echo "Without env var <gtm_passwd> set, MUPIP JOURNAL ROLLBACK failed as expected"
	exit
endif
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/dbcheck.csh
