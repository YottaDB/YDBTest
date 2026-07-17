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

# Summarize the work the MUPIP REORG -TRUNCATE tail sweep did, from the reorg's output (YDB#1245).
#
# The sweep reruns "mu_reorg" for each global whose blocks it finds past the truncate point, and each such run
# prints the same per-global block counters a normal reorg does. Attribute those counters to the sweep only:
# a "Truncate tail sweep of Global:" line starts a sweep section and a plain "Global:" line (printed by the
# reorg phase that runs before the sweep) ends it. The reorg phase's counters are deliberately left out --
# that phase still does full reorgs, splits and coalesces included.
#
# Set "sweep_guaranteed" to 1 only where the caller controls what the sweep finds, i.e. where no concurrent
# updates race the reorg. That enables the two reports that are otherwise meaningless as checks:
#
# 1) whether the sweep ran at all. It runs only if something is left past the truncate point when the reorg
#    phase finishes, and where concurrent updates decide that, it is a coin toss. In the reorg this subtest runs
#    alongside [initb^ydb1245], ^b1/^b2 are swept only if they get created after the reorg's "gv_select" builds
#    its global list; lose that race and the reorg phase handles them itself and the sweep has nothing to do.
#    A 28 stream run of this subtest had that happen in 5 streams, with the truncate landing on exactly the same
#    block counts either way.
#
# 2) the blocks swapped as a percentage of the blocks walked. It is entirely correct for the sweep to swap ALL
#    of a global's blocks if all of them happen to be past the truncate point, so where concurrent updates decide
#    how many that is, no threshold separates the intended behavior from a build that swaps every block
#    regardless. Runs of this subtest have produced 0%, 32% and 95% there, all correct.
#
# What IS worth checking either way is that the sweep did no splits/coalesces, so those are always reported. They
# are trivially 0 when the sweep does not run, which is harmless: the [-select] reorg, where "sweep_guaranteed"
# is 1, checks them against a sweep that is guaranteed to have run.
/^Truncate tail sweep of Global:/	{ insweep = 1; nsweep++; next }
/^Global:/				{ insweep = 0; next }
(0 == insweep)				{ next }
/^Blocks processed/			{ processed += $NF; next }
/^Blocks coalesced/			{ coalesced += $NF; next }
/^Blocks split/				{ nsplit += $NF; next }
/^Blocks swapped/			{ swapped += $NF; next }
END {
	if (1 == sweep_guaranteed)
		printf "Sweep ran                    : %s\n", (0 < nsweep) ? "YES" : "NO (test arrangement no longer exercises the sweep)"
	printf "Sweep blocks coalesced       : %d (must be 0: a coalesce does not move a block towards the front)\n", coalesced
	printf "Sweep blocks split           : %d (must be 0: a split does not move a block towards the front)\n", nsplit
	# Of the blocks the sweep walks, only those past the truncate point should get swapped. Bucket rather than
	# check an exact count: the caller arranges for only a few blocks to be past it, but exactly how few is not
	# worth pinning. A build that swaps every block it walks lands at ~100%, far above this bucket.
	if (1 == sweep_guaranteed)
	{
		pct = (0 < processed) ? int((100 * swapped) / processed) : 0
		printf "Sweep blocks swapped, as a %% of blocks walked : %s\n", (25 > pct) ? "UNDER 25%" : (pct "%")
	}
}
