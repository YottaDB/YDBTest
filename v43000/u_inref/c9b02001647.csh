#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

# track record c9b02-001647
# This test verifies that the file header is being periodically flushed to disk

# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh .
echo "# Check the Current transaction field before changes"
$DSE dump -fileheader >&! dse_dump_before.out
$grep "Current transaction" dse_dump_before.out

# do transactions to modify fileheader
$GTM <<EOF
set KILLPID=\$J
write "Performing 10 transactions for test",!
set ^A=1
for I=1:1:10 S ^A=^A+1
write "Put process to sleep for 10s"
hang 10
write "Kill process id GTM_TEST_DEBUGINFO:",KILLPID
zsystem "$kill9 "_KILLPID
EOF

echo "# get ftok id of mumps.dat"
setenv ftok_key `$MUPIP ftok -id=43 *.dat |& $grep -E "dat" | $tst_awk '{printf("%s ",substr($10, 2, 10));}'`
set dbipc_private = `$gtm_tst/com/db_ftok.csh`

echo "# do ipcrm"
$gtm_tst/com/ipcrm $dbipc_private
$gtm_tst/com/rem_ftok_sem.csh # arguments $ftok_key
echo "# rundown the database"
$gtm_exe/mupip rundown -file mumps.dat -override

echo "# Check the Current transaction field after changes"
$DSE dump -fileheader >& dse_dump_after.out
$grep "Current transaction" dse_dump_after.out
set cur_tn = `$tst_awk '/Current transaction/ {print $3}' dse_dump_after.out`
if("0x000000000000000C" == "$cur_tn") then
	echo "# Test Passed - file header was flushed."
else
	echo "TEST-E-FILEHEADER is not being flushed. Check dse_dump_*.out"
endif
$gtm_tst/com/dbcheck.csh
