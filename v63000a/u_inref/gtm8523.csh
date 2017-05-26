#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8523 - SIG-11 in GT.M in a TP transaction on an MM database with concurrent file extensions
#
echo "# This test requires MM (it tries to exercise concurrent-db-file-extension-logic in wcs_mm_recover)."
echo "# So force MM and therefore disable encryption as well (since that does not run with MM)."
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh	# Force NOBEFORE image journaling with MM
setenv gtm_test_spanreg 0		# The test expects a certain # of updates to fill the db allocation of DEFAULT

echo "# Since we need specific allocations/extension values for multiple regions, use a custom gde file."
setenv test_specific_gde $gtm_tst/$tst/u_inref/gtm8523.gde

echo "# Create two regions DEFAULT and AREG"
$gtm_tst/com/dbcreate.csh mumps 2

echo "# Populate nodes in database"
$gtm_dist/mumps -run init^gtm8523

echo "# Verify that DEFAULT region has NO free blocks (needed by parent^gtm8523). Exit test if verification fails"
$gtm_dist/mumps -run verify^gtm8523 >& verify.out
cat verify.out
$grep Exiting verify.out >& /dev/null
if (! $status) then
	exit -1
endif

echo "# Initialize white-box variables"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 122	# WBTEST_MM_CONCURRENT_FILE_EXTEND

echo "# Run backup in background"
(source $gtm_tst/$tst/u_inref/gtm8523_backup.csh >& backup.out & ; echo $! >&! backup_bg.pid) >&! backup_bg.out

echo "# Set gtm_wbox_mrtn to child^gtm8523 so this is spawned off by parent^gtm8523 when it reaches gdsfilext()"
setenv gtm_wbox_mrtn "child^gtm8523"

echo "# Run TP transaction which in turn spawns off a child to do the concurrent db file extension"
echo "# Without the code fix for GTM-8523, we expect a SIG-11 from this parent process inside gvcst_blk_build()"
$gtm_dist/mumps -run parent^gtm8523

echo "# Clear white-box variables"
setenv gtm_white_box_test_case_enable 0

echo "# Wait for background backup to finish"
set backup_pid = `cat backup_bg.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $backup_pid

echo "# Check db integrity"
$gtm_tst/com/dbcheck.csh
