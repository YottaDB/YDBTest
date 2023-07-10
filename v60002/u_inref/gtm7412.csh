#!/usr/local/bin/tcsh -f
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
# This module is derived from FIS GT.M.
#################################################################

setenv ydb_test_4g_db_blks 0	# Disable debug-only huge db scheme as this test is sensitive to block layout
				# and the huge HOLE in bitmap block 512 onwards disturbs the assumptions in this test.

echo "# Begin gtm7412 - check operator log for warnings when database extension=0"
# Get a random allocation value, between 512 and 10240 (inclusive of both end points)
# Note that for an allocation of 355 and 356, the FREEBLKSLOW message does not show up in the syslog
# (whereas it shows up for allocation of 354 or 357) because the GBLOFLOW message shows up even before that.
# This is because there is free space of 1 or 2 GDS blocks left at the point (whereas the FREEBLKSLOW message
# requires one bitmap block to become fully used) and the next SET in the FOR loop below requires requires
# 3 new blocks (1 new leaf block, 1 new level-1 index block due to block splits, 1 new level-2 root/index block).
# This causes test failures if we keep the range below 357. In real world usages, there will be at least a few
# bitmap blocks so this is not going to be an issue. Therefore keep at least 512 blocks in this test.
set alloc = `$gtm_exe/mumps -run rand 9729 1 512`
echo "# GTM_TEST_DEBUGINFO allocation : " $alloc

# Create database
$gtm_tst/com/dbcreate.csh mumps -allocation=$alloc -record=1010
$MUPIP set -exten=0 -region DEFAULT
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD 'for i=1:1 set ^a(i)=$justify(i,900)'
sleep 1		# to ensure getoper has a working window
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window1.txt
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "YDB-E-GBLOFLOW"
$gtm_tst/com/grepfile.csh "YDB-W-FREEBLKSLOW" syslog1.txt 1
$gtm_tst/com/dbcheck.csh
echo "# End gtm7412"
