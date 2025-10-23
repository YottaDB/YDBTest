#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Run [dbcreate.csh] to create database with 3 regions AREG, BREG and DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 3

echo '# Run [mumps -run startbg^ydb1178] to start a background process that updates all 3 regions'
$gtm_dist/mumps -run startbg^ydb1178

echo '# Run [MUPIP SET -MUTEX_TYPE=YDB -REG "*"]'
echo '# Pipe the output through [sort] to avoid arbitrary order of output (.dat file with lower inode gets printed first)'
$MUPIP set -mutex_type=YDB -reg "*" |& sort

echo "# Verify using DSE ALL -DUMP that Mutex Manager Type is YDB on all regions"
echo "# Note that if statshare is randomly enabled by test framework, DSE ALL -DUMP will also include stats regions"
echo "# (with lower case name). In that case, those should always show up with a Mutex Manager Type of YDB as"
echo "# that is the only value allowed currently for statsdb regions."
$DSE all -dump |& $grep -E "^Region |Mutex Manager Type"

echo "# Also verify the same (DSE output) using PEEKBYNAME"
echo "# This also verifies that mutex manager type can be obtained through PEEKBYNAME"
$gtm_dist/mumps -run getMutexType^ydb1178

echo "# Run [MUPIP SET -MUTEX_TYPE=PTHREAD -REG AREG,DEFAULT]"
$MUPIP set -mutex_type=PTHREAD -reg AREG,DEFAULT |& sort

echo "# Verify using DSE ALL -DUMP that Mutex Manager Type is PTHREAD in AREG and DEFAULT, YDB in BREG"
echo "# And because a background process is still updating the database files, this and later MUPIP SET -MUTEX_TYPE commands"
echo "# also verify that MUPIP SET -MUTEX_TYPE does not need standalone access to the database file."
$DSE all -dump |& $grep -E "^Region |Mutex Manager Type"

echo "# Also verify the same (DSE output) using PEEKBYNAME"
$gtm_dist/mumps -run getMutexType^ydb1178

echo "# Run [MUPIP SET -MUTEX_TYPE=ADAPTIVE -REG AREG]"
$MUPIP set -mutex_type=ADAPTIVE -reg AREG

echo "# Verify using DSE ALL -DUMP that Mutex Manager Type is ADAPTIVE in AREG, PTHREAD in DEFAULT, YDB in BREG"
$DSE all -dump |& $grep -E "^Region |Mutex Manager Type"

echo "# Also verify the same (DSE output) using PEEKBYNAME"
$gtm_dist/mumps -run getMutexType^ydb1178

echo "# Run [MUPIP SET -MUTEX_TYPE=PTHREAD -FILE b.dat]. To test that -MUTEX_TYPE -FILE also works."
$MUPIP set -mutex_type=PTHREAD -file b.dat

echo "# Verify using DSE ALL -DUMP that Mutex Manager Type is ADAPTIVE in AREG, PTHREAD in BREG and DEFAULT"
$DSE all -dump |& $grep -E "^Region |Mutex Manager Type"

echo "# Also verify the same (DSE output) using PEEKBYNAME"
$gtm_dist/mumps -run getMutexType^ydb1178

echo '# Verify using PEEKBYNAME and $ZPEEK that jnlpool crit mutex manager type is set to YDB (cannot be controlled by user)'
echo '# We expect a value of 2 to be seen below as that corresponds to YDB (3 corresponds to PTHREAD, 0 corresponds to ADAPTIVE)'
$gtm_dist/mumps -run %XCMD 'write "jnlpool Mutex Manager Type = ",$zpeek("JPCREPL",$$^%PEEKBYNAME("jnlpool_ctl_struct.critical_off",,"U"),4,"U"),!'

echo '# Run [mumps -run stopbg^ydb1178] to stop the background process that updates all 3 regions'
$gtm_dist/mumps -run stopbg^ydb1178

echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh

