#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

echo "# Test case to exercise a journal switch inside MUPIP JOURNAL RECOVER"

setenv gtm_test_spanreg     0       # Test requires traditional global mappings (^a->AREG, ^b->BREG), so disable spanning regions

echo "# Since there is nothing much to test without journaling on, enable it"
setenv gtm_test_jnl "SETJNL"
echo "# We want to exercise an autoswitch so use the smallest possible limit to reduce test runtime"
setenv tst_jnl_str "$tst_jnl_str,allocation=16384,autoswitch=16384"
echo "# This test requires BEFORE_IMAGE so set that unconditionally"
source $gtm_tst/com/gtm_test_setbeforeimage.csh

echo "Create journaled database for AREG,BREG,DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 3

set time1 = `date +'%d-%b-%Y %H:%M:%S'`
sleep 1	# so time of the next command is guaranteed to be 1 second greater than "$time1"

echo "Generate enough updates to cause autoswitch in GT.M and kill the process"
$GTM << GTM_EOF
	do ^autoswitch
GTM_EOF

echo "# Take backup of db and mjl for backward recover"
$gtm_tst/com/backup_dbjnl.csh bak "*.gld *.repl *.dat *.mjl*" cp nozip

# The kill -9 done above (inside "do ^autoswitch") can hit the process at the midst of wcs_wtstart in which case the # of
# dirty buffer and the active queue will be out-of-sync in db shared memory. This would result in the below mupip integ
# (invoked by dbcheck.csh) to assert fail in wcs_flu. To avoid the assert, white box test case 29
# (WBTEST_CRASH_SHUTDOWN_EXPECTED) needs to be defined.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29
$gtm_tst/com/dbcheck.csh

echo "# Take backup of db and mjl after dbcheck for later debugging if needed"
$gtm_tst/com/backup_dbjnl.csh bak2 "*.gld *.repl *.dat *.mjl*" mv nozip

echo "# Restore backup for backward recover"
cp bak/* .

echo "# Miss out on specifying b.mjl in order to create broken transactions in MUPIP JOURNAL"
set nonomatch = 1
echo $MUPIP journal -recover -back -noverify -since=\"$time1\" a.mjl,mumps.mjl -parallel=2
unset nonomatch
$MUPIP journal -recover -back -noverify -since=\"$time1\" a.mjl,mumps.mjl -parallel=2 >& mupjnl.out
echo "# We expect to see a FILERENAME message in the DEFAULT region in the forward phase of recovery"
$grep -E "Forward processing started at| : %YDB-I-FILERENAME" mupjnl.out
