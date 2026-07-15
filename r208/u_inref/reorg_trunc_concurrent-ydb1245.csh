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

echo "#-------------------------------------------------------------------------------------------#"
echo "# [#1245] MUPIP REORG -TRUNCATE frees up space even in the presence of concurrent updates #"
echo "#-------------------------------------------------------------------------------------------#"
echo

# MUPIP REORG -TRUNCATE is not supported with the MM access method so force BG
source $gtm_tst/com/gtm_test_setbgaccess.csh
# Disable V6 DB mode and the > 4g db block testing scheme as both change MUPIP REORG -TRUNCATE behavior/output
setenv gtm_test_use_V6_DBs 0
setenv ydb_test_4g_db_blks 0
# This subtest relies on all globals mapping to one region (DEFAULT) so disable spanning region randomization
setenv gtm_test_spanreg 0
# Do not let the test system run its own concurrent reorg processes; this subtest runs its own reorg with
# carefully arranged concurrent updates
setenv test_reorg NON_REORG

$gtm_tst/com/dbcreate.csh mumps 1 64 500 4096

echo "# Run [inita^ydb1245] : create ^a1 and ^a2 and kill ^a1 leaving lots of free space in the database file"
$ydb_dist/yottadb -run inita^ydb1245
echo "# Start [mupip reorg -truncate -reg DEFAULT] in the background"
# Launch inside a subshell (with the subshell output discarded) so the shell's job control messages
# ("[1] <pid>" and "[1] Done ...") do not end up in the subtest output.
($MUPIP reorg -truncate -reg DEFAULT >&! truncate_concurrent.out &; echo $! > reorg_pid.out) >&! /dev/null
@ reorg_pid = `cat reorg_pid.out`
echo "# Run [initb^ydb1245] : create ^b1 and ^b2 concurrently with the reorg -truncate"
$ydb_dist/yottadb -run initb^ydb1245
echo "# Wait for the background reorg -truncate to complete"
$gtm_tst/com/wait_for_proc_to_die.csh $reorg_pid 600
echo "# Run a standalone [mupip reorg -truncate -reg DEFAULT] for comparison"
$MUPIP reorg -truncate -reg DEFAULT >&! truncate_standalone.out

echo
echo "# Verify the concurrent reorg -truncate truncated the database file"
echo "# A YDB build without the YDB#1245 fixes used to produce the following output here instead"
echo "#	%YDB-I-MUTRUNCALREADY, Region DEFAULT: no further truncation possible"
echo "# whereas we now expect the [Truncated region: DEFAULT] line below"
# The [Truncated region] line's block counts are normalized below before becoming part of the reference file.
# The pre-truncate free blocks count depends on the exact interleaving of the concurrent updates with the reorg
# phase (e.g. how much block coalescing happened before a given block got its final content) so it is replaced
# with [ARBITRARY]. The post-truncate counts can also vary a little in the rare case the background reorg's
# truncate phase runs before the tail end of the concurrent updates, so they are checked against bounds derived
# from what a standalone REORG -TRUNCATE of the same data achieves (total blocks at most 12800, free blocks less
# than 200) instead of exact values. A MUTRUNCALREADY message or a partially effective truncate (e.g. a total
# blocks count of 17408, seen with only some of the YDB#1245 fixes in place) shows up as a reference file
# difference either way.
grep -q "Truncated region: DEFAULT" truncate_concurrent.out
if (0 != $status) then
	echo "FAIL: concurrent reorg -truncate did not truncate region DEFAULT"
	echo "# ----- truncate_concurrent.out -----"
	cat truncate_concurrent.out
	echo "# ----- truncate_standalone.out -----"
	cat truncate_standalone.out
else
	grep "Truncated region: DEFAULT" truncate_concurrent.out | awk '{split($0, a, "[][]"); tto = ((a[4] + 0) <= 12800) ? "12800 OR LESS" : a[4]; fto = ((a[8] + 0) < 200) ? "LESS THAN 200" : a[8]; printf "Truncated region: DEFAULT. Reduced total blocks from [%s] to [%s]. Reduced free blocks from [ARBITRARY] to [%s].\n", a[2], tto, fto;}'
endif

$gtm_tst/com/dbcheck.csh
