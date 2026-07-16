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
# Set "show_swap_pct" to 1 to also report the blocks swapped as a percentage of the blocks walked. Only do that
# where the caller controls how many blocks are past the truncate point. Where concurrent updates decide that
# (i.e. the reorg this subtest runs alongside [initb^ydb1245]) the percentage is meaningless as a check: it is
# entirely correct for the sweep to swap ALL of a global's blocks if all of them happen to be past the truncate
# point, so no threshold separates the intended behavior from a build that swaps every block regardless. Runs of
# this subtest have produced anything from 0% to 32% there.
/^Truncate tail sweep of Global:/	{ insweep = 1; nsweep++; next }
/^Global:/				{ insweep = 0; next }
(0 == insweep)				{ next }
/^Blocks processed/			{ processed += $NF; next }
/^Blocks coalesced/			{ coalesced += $NF; next }
/^Blocks split/				{ nsplit += $NF; next }
/^Blocks swapped/			{ swapped += $NF; next }
END {
	# The sweep runs only if the concurrent updates left busy blocks past the truncate point. That is what this
	# subtest arranges, but how many blocks (and of how many globals) is timing dependent, so normalize.
	printf "Sweep ran                    : %s\n", (0 < nsweep) ? "YES" : "NO (test arrangement no longer exercises the sweep)"
	printf "Sweep blocks coalesced       : %d (must be 0: a coalesce does not move a block towards the front)\n", coalesced
	printf "Sweep blocks split           : %d (must be 0: a split does not move a block towards the front)\n", nsplit
	# Of the blocks the sweep walks, only those past the truncate point should get swapped. Bucket rather than
	# check an exact count: the caller arranges for only a few blocks to be past it, but exactly how few is not
	# worth pinning. A build that swaps every block it walks lands at ~100%, far above this bucket.
	if (1 == show_swap_pct)
	{
		pct = (0 < processed) ? int((100 * swapped) / processed) : 0
		printf "Sweep blocks swapped, as a %% of blocks walked : %s\n", (25 > pct) ? "UNDER 25%" : (pct "%")
	}
}
