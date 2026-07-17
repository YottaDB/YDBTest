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

# Normalize the [Truncated region: DEFAULT] line of a MUPIP REORG -TRUNCATE output so it can be part of the
# reorg_trunc_hidden_gbl-ydb1240 subtest's reference file. The exact block counts depend on record/block
# packing details (e.g. 32- versus 64-bit block ids) so they are checked against bounds instead:
#   - the pre-truncate total must exceed 1024 blocks: the setup grew the file across at least 3 local bitmaps
#     (512 blocks each), and a value at or under 1024 means the setup did not create what the truncate is
#     supposed to reclaim;
#   - the post-truncate total must be at most 1024: once the hidden globals' blocks are moved to the front,
#     everything busy fits well inside the first local bitmap, and "mu_truncate" cuts the file at a local
#     bitmap boundary above the highest busy block (so 512, or 1024 if a straggler sits just above 512);
#   - the post-truncate free count must be under 1024: it is essentially the gap between the highest busy
#     block and the bitmap boundary above it (0 to 511 by construction) plus the few free blocks below.
# The pre-truncate free count is as arbitrary as the packing details that produce it, and (unlike the
# pre-truncate total) nothing about it makes or breaks the truncate, so it is not bounded, just replaced.
#
# A caller whose reorg output has no [Truncated region: DEFAULT] line at all gets no output from this script;
# callers detect that case themselves (they cat the reorg output, which then shows up as a reference file
# difference).
/Truncated region: DEFAULT/ {
	split($0, a, "[][]");
	tfrom = ((a[2] + 0) > 1024) ? "MORE THAN 1024" : a[2];
	tto = ((a[4] + 0) <= 1024) ? "1024 OR LESS" : a[4];
	fto = ((a[8] + 0) < 1024) ? "LESS THAN 1024" : a[8];
	printf "Truncated region: DEFAULT. Reduced total blocks from [%s] to [%s]. Reduced free blocks from [ARBITRARY] to [%s].\n", tfrom, tto, fto;
}
