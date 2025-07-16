#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE551455 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE551455)

GT.M creates STATSDB regions with FREEZE_ON_ERROR disabled, preventing errors associated with such regions from causing an instance freeze when the INST_FREEZE_ON_ERROR policy is enabled. Previously, GT.M used the value of FREEZE_ON_ERROR from the associated base region for the STATSDB region. (GTM-DE551455)

CAT_EOF
echo

setenv gtm_repl_instance "mumps.repl"
$MULTISITE_REPLIC_PREPARE 2

# Copy test routine from v70001/gtm9131 test to reuse job^gtm9131 label below
# to open DEFAULT region and trigger creation of STATSDB.
cp $gtm_tst/v70001/inref/gtm9131.m .

echo "# The following test cases do not produce an error to test FREEZE_ON_ERROR in STATSDB regions"
echo "# since the easiest error to test is GVSUBOFLOW, but this requires setting an extension size of 0 blocks for the given region."
echo "# In this case, that region would be a STATSDB region, but users cannot set the extension size for a STATSDB region."
echo "# Therefore this test just verifies that the FREEZE_ON_ERROR field in the STATSDB is always disabled,"
echo "# regardless of the INST_FREEZE_ON_ERROR policy of the base region."
echo "# For more background, see the discussion at: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/700#note_2647026523"
echo

echo "### Test 1: STATSDB regions are created with FREEZE_ON_ERROR disabled when INST_FREEZE_ON_ERROR policy is disabled in the base db"
echo "# Disable INST_FREEZE_ON_ERROR policy on all regions"
setenv gtmgbldir T1.gld
echo "# Set gtm_test_freeze_on_error=0 to override possibly conflicting random test setting"
setenv gtm_test_freeze_on_error 0
$gtm_tst/com/dbcreate.csh T1 >& dbcreateT1.log
echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo

echo "# Start process in background to have DEFAULT region open for the duration of the test and trigger creation of STATSDB"
$gtm_dist/mumps -run job^gtm9131 1 2	# parameter 1 indicates 1 job to start, parameter 2 indicates jobid=2
echo "# Verify FREEZE_ON_ERROR=0 (disabled) for STATSDB region (previously, FREEZE_ON_ERROR=0 (disabled) was also expected, since this is the policy on the base region):"
$gtm_dist/mumps -run %XCMD 'write "FREEZE_ON_ERROR: "_$$^%PEEKBYNAME("sgmnt_data.freeze_on_fail","default"),!'
echo "# Stop background process"
$gtm_dist/mumps -run stop^gtm9131 2	# parameter 2 indicates stop all jobs started with jobid=2
echo
echo "# Stop INST1 INST2 replication"
$MSR STOP INST1 INST2
echo

echo "### Test 2: STATSDB regions are created with FREEZE_ON_ERROR disabled when INST_FREEZE_ON_ERROR policy is enabled in the base db"
echo "# Enable INST_FREEZE_ON_ERROR policy on all regions"
setenv gtmgbldir T2.gld
echo "# Set gtm_test_freeze_on_error=1 to override possibly conflicting random test setting"
setenv gtm_test_freeze_on_error 1
$gtm_tst/com/dbcreate.csh T2 >& dbcreateT2.log
$gtm_dist/mupip set -inst_freeze_on_error -reg "*"
echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo

echo "# Start process in background to have DEFAULT region open for the duration of the test and trigger creation of STATSDB"
$gtm_dist/mumps -run job^gtm9131 1 2	# parameter 1 indicates 1 job to start, parameter 2 indicates jobid=2
echo "# Verify FREEZE_ON_ERROR=0 (disabled) for STATSDB region (previously, FREEZE_ON_ERROR=1 (enabled) was expected, since that is the policy on the base region):"
$gtm_dist/mumps -run %XCMD 'write "FREEZE_ON_ERROR: "_$$^%PEEKBYNAME("sgmnt_data.freeze_on_fail","default"),!'
echo "# Stop background process"
$gtm_dist/mumps -run stop^gtm9131 2	# parameter 2 indicates stop all jobs started with jobid=2
echo
echo "# Stop INST1 INST2 replication"
$MSR STOP INST1 INST2
echo

$gtm_tst/com/dbcheck.csh
