#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1300] A MUPIP STOP of a process waiting for disk space no longer exits holding the journal    #"
echo "# pool lock                                                                                          #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# When a write gets ENOSPC and instance freeze is enabled for DSKNOSPCAVAIL, wait_for_disk_space() takes"
echo "# the journal pool lock, freezes the instance and retries the write. A MUPIP STOP made it exit right there."
echo "# If a commit was underway, the exit handler found the journal pool lock still held and a Debug build"
echo "# failed an assert in secshr_db_clnup() (and left the buffer being written owned by the dead process)."
echo "#"
echo "# This test needs a Debug build: gdb turns on the debug-only fake ENOSPC at a"
echo "# chosen point in process A. Each stage then stops A with MUPIP STOP while it waits for disk space,"
echo "# checks that A terminates with FORCEDHALT and no assert failure, and that process B can then update"
echo "# the same globals. Without the fix, A fails an assert in secshr_db_clnup() in stage 1, and the state"
echo "# that leaves makes the later stages report WRONG as well."
echo

# The fake ENOSPC is set from gdb below, so turn off the random fake ENOSPC done by the source server.
# Instance freeze on DSKNOSPCAVAIL needs -inst_freeze_on_error and a custom errors file that lists it.
# Asyncio database writes and MM do not go through wait_for_disk_space() in the same way, so use BG without asyncio.
setenv gtm_test_fake_enospc 0
setenv gtm_test_freeze_on_error 1
setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
setenv acc_meth BG
setenv gtm_test_asyncio 0
echo "setenv gtm_test_fake_enospc 0"						>> settings.csh
echo "setenv gtm_test_freeze_on_error 1"					>> settings.csh
echo "setenv gtm_custom_errors $gtm_custom_errors"				>> settings.csh
echo "setenv acc_meth BG"							>> settings.csh
echo "setenv gtm_test_asyncio 0"						>> settings.csh

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
# A flush timer that comes due 100 milliseconds after an update keeps the gdb waits below short
$MUPIP set -flush_time=100 -region "*" >&! mupip_set.out
if ($status) then
	echo "# MUPIP SET failed. Output follows."
	cat mupip_set.out
endif

echo "# Start the source and receiver servers"
$MSR START INST1 INST2

# Process B turns the fake ENOSPC off again (nothing else would, as the source server stays alive). It stops in the
# first t_end() for the region that has it on, as other regions (e.g. a statsdb region) can be updated first.
cat > gdb_b.cmd << CAT_EOF
set breakpoint pending on
set confirm off
set pagination off
break t_end if cs_addrs->nl->fake_db_enospc || cs_addrs->nl->fake_jnl_enospc
run
delete
set var cs_addrs->nl->fake_db_enospc = 0
set var cs_addrs->nl->fake_jnl_enospc = 0
detach
quit
CAT_EOF

echo
echo "# Stage 1 : a database write by the flush timer at the end of a TP commit gets ENOSPC"
$gtm_tst/$tst/u_inref/enospc_mupip_stop_stage-ydb1300.csh dbtp
echo "# Stage 2 : a journal write by the flush timer at the end of a TP commit gets ENOSPC"
$gtm_tst/$tst/u_inref/enospc_mupip_stop_stage-ydb1300.csh jnltp
echo "# Stage 3 : as stage 1, and another process then changes the instance freeze (DSKNOSPCBLOCKED)"
$gtm_tst/$tst/u_inref/enospc_mupip_stop_stage-ydb1300.csh blocked
echo "# Stage 4 : a database write done while holding crit in phase 1 of a TP commit gets ENOSPC"
$gtm_tst/$tst/u_inref/enospc_mupip_stop_stage-ydb1300.csh crit

echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
