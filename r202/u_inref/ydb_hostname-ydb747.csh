#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# Test that ydb_hostname env var overrides actual hostname in database file header (node_local.machine_name)'
echo ''
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo ''
set hostname255bytes="ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE12345ABCDE"

echo '# Test 1: Set ydb_hostname to TESTHOSTNAME'
echo '# Expected output of node_local.machine_name in database file header to be TESTHOSTNAME'
setenv ydb_hostname TESTHOSTNAME
$gtm_dist/mumps -run ydb747
echo ''
echo '# Test 2: Set ydb_hostname length=255 (Maximum hostname length - 1)'
echo '# Expected output of node_local.machine_name in database file header to be ##255-byte-long-hostname##'
setenv ydb_hostname $hostname255bytes
$gtm_dist/mumps -run ydb747
echo ''
echo '# Test 3: Set ydb_hostname length=256 (Maximum hostname length)'
echo '# Expect node_local.machine_name in database file header to truncate at 255, as that is the behavior of strncpy().'
echo '# So it should output the same thing as the Test #2 (##255-byte-long-hostname##).'
setenv ydb_hostname $hostname255bytes"Z"
$gtm_dist/mumps -run ydb747
echo ''
echo '# Test 4: Set ydb_hostname length=257 (Maximum hostname length + 1)'
echo '# Also expect node_local.machine_name in database file header this to truncate at 255.'
echo '# So it should output the same thing as the Test #2 (##255-byte-long-hostname##).'
setenv ydb_hostname $hostname255bytes"ZZ"
$gtm_dist/mumps -run ydb747
unsetenv ydb_hostname
echo ''
echo '# Check database integrity'
$gtm_tst/com/dbcheck.csh
