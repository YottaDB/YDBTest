#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
GTM-F166755 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-F166755)

By default, the MUPIP BACKUP -DATABASE retries file copy operation once if the first attempt fails for a retriable reason;
this is equivalent to -RETRY=1. -RETRY=0 prevents any retries, so if the copy fails MUPIP immediately reports an error.
Additionally, any copy failure error messages include region information when displaying OS service error codes.
Previously, while the default was equivalent to -RETRY=1 that incorrectly meant one BACKUP attempt, -RETRY=0 did not perform
a backup, and error reports did not identify the region associated with the failure. (GTM-F166755)
CAT_EOF
echo
setenv ydb_msgprefix "GTM"
echo '# According to release note, There are 4 cases that will need to be tested'
echo '# 1) MUPIP BACKUP -DATABASE equivalent to MUPIP BACKUP -DATABASE -RETRY=1'
echo '# 2) -RETRY=0 will perform backup without any retries'
echo '# 3) RETRY=1 fails the first attempt but succeeds in the retry'
echo '# 4) Copy failure error messages include region information when displaying OS service error codes'
echo ''
echo '# But some tests already tested (Discussion in https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2043#note_201410428)'
echo ''
echo '# From the discussion, We concluded that this test will only test 2 topics from release note.'
echo '# 1) MUPIP BACKUP -DATABASE equivalent to MUPIP BACKUP -DATABASE -RETRY=1'
echo '# 2) -RETRY=0 will perform backup without any retries'
echo
echo '# And topics will NOT get tested in this test:'
echo '# 3) RETRY=1 fails the first attempt but succeeds in the retry (Tested in v70001/gtm9424)'
echo '# 4) Copy failure error messages include region information when displaying OS service error codes (Tested in v70001/gtm9424)'
echo
echo '# Creating database file region DEFAULT'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Test 1) MUPIP BACKUP -DATABASE equivalent to MUPIP BACKUP -DATABASE -RETRY=1'
echo '# With GT.M V7.1-000 and later, no retries will be attempted for either MUPIP BACKUP -DATABASE or'
echo '# MUPIP BACKUP -DATABASE -RETRY=1 when an error occurs during the copy phase of the backup.'
echo '# With V7.0-004 and later, this would perform 1 backup attempt with 1 retry.'
echo '# Prior to GT.M V7.0-004, this would perform 1 backup attempt without any retries'
echo
echo '# Create temporary destination file'
mkdir bak1/
echo '# Create destination file'
touch bak1/mumps.dat
echo
echo '# Change the permission to make this file not writable (This will cause BKUPFILEPERM error)'
chmod -w bak1/mumps.dat
echo '# Perform  MUPIP BACKUP -DATABASE for region DEFAULT'
echo '# Need to use [-replace] to be able to overwrite an existing target file'
$MUPIP backup -replace -DATABASE "DEFAULT" bak1/mumps.dat >& bak1_1.outx; $grep -Ev 'FILERENAME|JNLCREATE' bak1_1.outx
echo
echo '# Perform MUPIP BACKUP -DATABASE "DEFAULT" -RETRY=1 for region DEFAULT'
$MUPIP backup -replace -DATABASE "DEFAULT" -RETRY=1 bak1/mumps.dat >& bak1_2.outx; $grep -Ev 'FILERENAME|JNLCREATE' bak1_2.outx
echo
echo '# Test 2) -RETRY=0 will perform backup without any retries.'
echo '# Previously, This will not perform backup and and error reports will not identify the region associated with the failure'
echo
echo '# Note : There is an issue in the GT.M version older than V7.0-004 which says "Backup completed successfully"'
echo '# Even though it not doing any backup at all, which is wrong. So, the output is not matched with release note message below:'
echo '# "Error reports will not identify the region associated with the failure"'
echo '# Discussion in https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2043#note_2033422017'
echo
echo '# Create temporary destination file'
mkdir bak2/
touch bak2/mumps.dat
echo
echo '# Change the permission to make this file not writable'
chmod -w bak2/mumps.dat
echo
echo '# Now Perform backup region DEFAULT with -RETRY=0'
echo '# Expected no retry attempt'
$MUPIP backup -replace -retry=0 "DEFAULT" bak2/mumps.dat >& bak2.outx; $grep -Ev 'FILERENAME|JNLCREATE' bak2.outx
echo
echo '# Check for database integrity'
$gtm_tst/com/dbcheck.csh
