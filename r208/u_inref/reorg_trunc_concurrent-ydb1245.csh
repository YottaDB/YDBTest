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
# The reorg below is optionally run under strace to count the database file reads/writes it does (see further
# below). That counting only works with asyncio turned off: with asyncio on, the database block writes go through
# io_submit() rather than pwrite() and would not be counted at all. Rather than turn asyncio off for the whole
# subtest (which would lose the coverage of running the concurrent REORG -TRUNCATE with asyncio on) just skip the
# counting in that case. The check in question prints nothing when it passes, so the subtest output is the same
# either way. Note "gtm_test_asyncio" is defaulted below before being tested: do_random_settings.csh always sets
# it, but the subtest can be run standalone, and tcsh substitutes the variable while scanning an [else if] line
# even when that branch is not taken (so testing $?gtm_test_asyncio in an [if]/[else if] chain does not work).
if (! $?gtm_test_asyncio) setenv gtm_test_asyncio 0
if (1 == "$gtm_test_asyncio") then
	set count_db_io = 0
else
	set count_db_io = 1
endif

$gtm_tst/com/dbcreate.csh mumps 1 64 500 4096

echo "# Run [inita^ydb1245] : create ^a1 and ^a2 and kill ^a1 leaving lots of free space in the database file"
$ydb_dist/yottadb -run inita^ydb1245
echo "# Start [mupip reorg -truncate -reg DEFAULT] in the background"
# Launch inside a subshell (with the subshell output discarded) so the shell's job control messages
# ("[1] <pid>" and "[1] Done ...") do not end up in the subtest output.
# When counting the reorg's database I/O (see "count_db_io" above) the reorg is run under strace. Notes:
#  - "-y" makes strace print the path behind each file descriptor, which is what lets the counting below tell
#    reads/writes of the database file apart from those of the journal file (both are pread/pwrite).
#  - "$!" is then strace's pid, not the reorg's. That is what we want to wait on either way: strace exits once
#    the process it traces does.
#  - strace slows the reorg down (every syscall traps), which gives [initb^ydb1245] below more of a head start
#    than it would otherwise have. That only changes how many blocks the concurrent updates leave past the
#    truncate point, which this subtest already treats as arbitrary (see the normalizing below).
if (1 == $count_db_io) then
	(strace -qq -y -e trace=pread64,pwrite64 -o reorg_syscalls.outx $MUPIP reorg -truncate -reg DEFAULT >&! truncate_concurrent.out &; echo $! > reorg_pid.out) >&! /dev/null
else
	($MUPIP reorg -truncate -reg DEFAULT >&! truncate_concurrent.out &; echo $! > reorg_pid.out) >&! /dev/null
endif
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
# truncate phase runs before the tail end of the concurrent updates, so they are checked against bounds instead
# of exact values. A MUTRUNCALREADY message or a partially effective truncate (e.g. a total blocks count of
# 17408, seen with only some of the YDB#1245 fixes in place) shows up as a reference file difference either way.
#
# The total blocks bound is what really matters here and comes from what a standalone REORG -TRUNCATE of the same
# data achieves: at most 12800. The concurrent one can do BETTER than that (a measured run truncated to 11776),
# since a truncate that happens before the concurrent updates finish sees fewer busy blocks.
#
# The free blocks left behind are bounded much more loosely, because they are essentially just the gap between
# the highest busy block and the local bitmap boundary above it: "mu_truncate" frees space a local bitmap at a
# time, so it leaves everything from the highest busy block up to the next multiple of BLKS_PER_LMAP. That gap is
# 0 to 511 by construction and is set by wherever the concurrent updates happened to leave the last busy block.
# Measured runs: 83 free after truncating to 12800 (= 25 * 512), and 426 after truncating to 11776 (= 23 * 512).
# Hence the 1024 below: two bitmaps' worth, i.e. the structural 511 plus room for free blocks the concurrent
# updates leave scattered below. It is not a compaction check (the total blocks bound above is), just a guard
# against the truncate leaving an absurd amount of free space behind.
grep -q "Truncated region: DEFAULT" truncate_concurrent.out
if (0 != $status) then
	echo "FAIL: concurrent reorg -truncate did not truncate region DEFAULT"
	echo "# ----- truncate_concurrent.out -----"
	cat truncate_concurrent.out
	echo "# ----- truncate_standalone.out -----"
	cat truncate_standalone.out
else
	grep "Truncated region: DEFAULT" truncate_concurrent.out | awk '{split($0, a, "[][]"); tto = ((a[4] + 0) <= 12800) ? "12800 OR LESS" : a[4]; fto = ((a[8] + 0) < 1024) ? "LESS THAN 1024" : a[8]; printf "Truncated region: DEFAULT. Reduced total blocks from [%s] to [%s]. Reduced free blocks from [ARBITRARY] to [%s].\n", a[2], tto, fto;}'
endif

echo
echo "# Verify the truncate tail sweep does only the work that helps the truncate"
echo "#"
echo "# The sweep reruns [mu_reorg] for each global whose blocks it finds past the truncate point. A block swap is"
echo "# the only reorg operation that moves a block towards the front of the file, so the sweep asks for swaps only"
echo "# (no splits/coalesces) and only for blocks that lie past the truncate point. Without those restrictions the"
echo "# sweep rewrites a global's ENTIRE tree to relocate the handful of blocks that are actually in the way; in a"
echo "# user database, where a single global routinely occupies a gigabyte, that is a great deal of needless work"
echo "# (every swap/split/coalesce is a transaction, with journal records and before-images) and the reorg takes"
echo "# correspondingly longer. Rather than time the reorg (wall clock timings are far too noisy on a loaded test"
echo "# system to assert on), verify the work itself, using the per-global block counters that [mu_reorg] prints."
echo "# The counters below cover only the sweep's [Truncate tail sweep of Global:] sections, not the reorg phase"
echo "# that precedes them (that phase still does full reorgs, splits and coalesces included). Only the"
echo "# splits/coalesces are checked here. Neither whether the sweep ran at all, nor how many blocks it swapped,"
echo "# is deterministic for this reorg: ^b1/^b2 are swept only if [initb^ydb1245] creates them after the reorg's"
echo "# [gv_select] has built its list of globals, and if it loses that race the reorg phase handles them itself"
echo "# and the sweep has nothing left to do (a 28 stream run had that in 5 streams, with the truncate landing on"
echo "# the same block counts either way). And where the updates decide how many blocks end up past the truncate"
echo "# point, it is entirely correct for the sweep to swap ALL of a global's blocks if that is where they all"
echo "# are, so no bound on the swaps separates the intended behavior from a build that swaps every block"
echo "# regardless. The [-select] reorg further below, which no updates race, is where both get checked."
$tst_awk -v sweep_guaranteed=0 -f $gtm_tst/r208/inref/sweep_stats-ydb1245.awk truncate_concurrent.out

echo
echo "# Smoke test the database file writes the reorg actually did"
echo "#"
echo "# The block counters above are what [mu_reorg] believes it did. Corroborate them, loosely, against the"
echo "# pwrite() calls the reorg process really issued against the database file, counted from an strace of it."
echo "# Loosely because the count covers the whole reorg and its reorg phase dominates: in a measured run that"
echo "# phase swapped 10569 blocks to the sweep's 1. So this cannot see the sweep's savings (the block counters"
echo "# above are what verify those); it only catches the reorg's writes growing by an order of magnitude, i.e."
echo "# the saved work coming back as real I/O somewhere else. Only writes are checked: the sweep still WALKS"
echo "# whole global variable trees (that is how it locates the blocks past the truncate point transactionally)"
echo "# so its reads are expected to stay, whereas what the YDB#1245 work removes is write work (block swaps,"
echo "# splits and coalesces) and the reads incidental to it. Nothing is printed below if the check passes, or"
echo "# if it is skipped because asyncio is on (which routes the block writes through io_submit() instead of"
echo "# pwrite(), making them uncountable this way)."
if (1 == $count_db_io) then
	# [dbcreate.csh mumps] above created the region DEFAULT database as mumps.dat in the subtest directory.
	# Journal file I/O uses pread/pwrite too, hence the select on the database file name that [strace -y] prints.
	@ dbreads = `grep -c '^pread64(.*mumps\.dat' reorg_syscalls.outx`
	@ dbwrites = `grep -c '^pwrite64(.*mumps\.dat' reorg_syscalls.outx`
	# This is a SMOKE TEST, not a check of the sweep's savings. The count covers the whole reorg, and the reorg
	# phase (whose share is unchanged by the YDB#1245 work) dominates it: in a measured run the phase swapped
	# 10569 blocks against the sweep's 1, for 13159 database writes in total. A sweep regressed to rewriting the
	# globals it touches in full would add only ~1300 writes to that (~1000 extra swaps, at the ~1.25 writes per
	# swap the same run shows), i.e. ~10%, which is far too close to the noise of a loaded test system to assert
	# on. The precise, sweep-only check is the block counter one above; the bound here is set well clear of the
	# measured 13159 and only fires if the reorg's database writes grow by an order of magnitude.
	if ((0 >= $dbreads) || (131072 <= $dbwrites)) then
		echo "FAIL: unexpected database file I/O from the concurrent reorg -truncate"
		echo "#	mumps.dat pread() calls  : $dbreads (expected at least 1; 0 => strace captured nothing)"
		echo "#	mumps.dat pwrite() calls : $dbwrites (expected far fewer than 131072; a measured run"
		echo "#	                          did 13159)"
		echo "# ----- truncate_concurrent.out -----"
		cat truncate_concurrent.out
	endif
endif

echo
echo "# Measure the tail sweep's savings with the reorg phase taken out of the picture"
echo "#"
echo "# The database write count above is dominated by the reorg phase, which the YDB#1245 work does not change,"
echo "# so it cannot see the sweep's savings. Set up a database where the sweep is the only thing doing any"
echo "# appreciable work and the count becomes a direct measure of them: ^a2 compacted at the front of the file,"
echo "# a few of its blocks stranded at the very end, and a large free region in between (see [initc^ydb1245]);"
echo "# then reorg with -SELECT=a1,filler, which reorgs only killed globals and so costs nothing. The sweep walks"
echo "# ^a2 (~10000 blocks) but should swap only the few blocks that are actually past the truncate point. A"
echo "# build without the YDB#1245 work swaps every one of the blocks it walks instead, which is two orders of"
echo "# magnitude more database writes."
echo "# Run [killb^ydb1245] : kill ^b1 and ^b2 to free up the space they occupy"
$ydb_dist/yottadb -run killb^ydb1245
echo "# Run [mupip reorg -truncate -reg DEFAULT] : compact ^a2 to the front of the database file"
$MUPIP reorg -truncate -reg DEFAULT >&! truncate_compact.out
echo "# Run [initc^ydb1245] : strand a few ^a2 blocks at the end of the file with free space below them"
$ydb_dist/yottadb -run initc^ydb1245
# Note ^filler is selected below alongside ^a1 even though [initc^ydb1245] killed it. Killing a global leaves
# its (now empty) GVT root block behind, and ^filler's root was allocated late in its growth, i.e. near the end
# of the file. Nothing else in this reorg would move that block: the tail sweep skips empty blocks (with no key
# in them there is no global name to look up, see mu_trunc_tail_sweep.c) and "mu_swap_root" only walks selected
# globals. One busy block in the last local bitmap is enough to pin the whole file, since "mu_truncate" frees
# space a local bitmap at a time (new_total = highest bitmap with a busy block + BLKS_PER_LMAP), so leaving it
# there costs the sweep's work its entire payoff: measured at MUTRUNCALREADY with -select=a1, versus a truncate
# from 15963 blocks down to 10752 with -select=a1,filler. Reorging ^filler costs one block swap.
echo "# Run [mupip reorg -truncate -select=a1,filler -reg DEFAULT] : only the tail sweep does any real work"
if (1 == $count_db_io) then
	strace -qq -y -e trace=pwrite64 -o select_syscalls.outx $MUPIP reorg -truncate -select="a1,filler" -reg DEFAULT >&! truncate_select.out
else
	$MUPIP reorg -truncate -select="a1,filler" -reg DEFAULT >&! truncate_select.out
endif
# This reorg has no concurrent updates racing it, so unlike the one above its sweep counters are deterministic:
# [initc^ydb1245] put a known handful of ^a2's ~10000 blocks past the truncate point, so the sweep is guaranteed
# to run and the swaps are worth checking here (a build that swaps every block it walks reports ~100% instead).
# These checks work whether or not the strace based one below runs, since they read the reorg's own output
# rather than counting system calls.
$tst_awk -v sweep_guaranteed=1 -f $gtm_tst/r208/inref/sweep_stats-ydb1245.awk truncate_select.out
# And check the sweep's work actually bought a truncate. Without this it is possible for the sweep to do exactly
# the right thing and the file to still not shrink by a single block, because one busy block left in the last
# local bitmap pins the whole file (see the -select comment above).
grep -q "Truncated region: DEFAULT" truncate_select.out
if (0 == $status) then
	echo "Truncated the file after the sweep : YES"
else
	echo "Truncated the file after the sweep : NO"
	echo "# ----- truncate_select.out -----"
	cat truncate_select.out
endif
if (1 == $count_db_io) then
	# With the reorg phase reduced to the killed ^a1, essentially every database write this process does comes
	# from the sweep, so the bound below is a real check of the sweep's savings rather than the smoke test
	# above: a sweep that swapped every block it walked would need roughly as many writes as ^a2 has blocks.
	@ selectwrites = `grep -c '^pwrite64(.*mumps\.dat' select_syscalls.outx`
	if (2000 <= $selectwrites) then
		echo "FAIL: the -SELECT=a1 reorg -truncate did $selectwrites database writes (expected far fewer than"
		echo "#	2000; is the tail sweep swapping every block of ^a2 rather than only those past the"
		echo "#	truncate point?)"
		echo "# ----- truncate_select.out -----"
		cat truncate_select.out
	endif
endif

echo
echo "# Verify [mupip reorg -noswap -truncate] skips the tail sweep altogether"
echo "# A block swap is the only thing the sweep does, so with -NOSWAP it could not move anything and would be all"
echo "# cost (the bitmap scan) and no benefit. Expect no [Truncate tail sweep of Global:] output at all below."
$MUPIP reorg -noswap -truncate -reg DEFAULT >&! truncate_noswap.out
echo -n "Tail sweep sections in a -NOSWAP reorg -truncate : "
grep -c "Truncate tail sweep of Global:" truncate_noswap.out

$gtm_tst/com/dbcheck.csh
