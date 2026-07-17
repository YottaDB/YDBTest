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

# Normalize the [Truncated region: DEFAULT] line for stage H of the reorg_trunc_hidden_gbl-ydb1240 subtest,
# where a large hidden global ^bigh (~1330 blocks) sat at the tail of the file with a large free region (the
# killed ^x filler) ahead of it. A truncate is only possible if ^bigh's blocks were first relocated to the
# front of the file, so the truncate happening at all -- and the total dropping from "roughly ^x + ^bigh" to
# "roughly ^bigh" -- is the proof that the relocation happened. Exact counts depend on record/block packing
# (e.g. 32- vs 64-bit block ids), so they are checked against bounds instead:
#   - the pre-truncate total must exceed 3072 blocks: ^x (front) plus ^bigh (tail) together, i.e. the file
#     the setup built before anything was relocated;
#   - the post-truncate total must be between 512 and 2560 blocks: ^bigh alone, now compacted at the front,
#     with the ^x-sized free tail cut away. It is well above 512 (^bigh spans several local bitmaps) and well
#     below the pre-truncate total (the free ^x region is gone). A build that failed to relocate ^bigh would
#     instead leave the total near its pre-truncate value or issue MUTRUNCALREADY, either of which shows up
#     as a reference file difference.
# Both free-block counts are as arbitrary as the packing details that produce them, so they are replaced.
/Truncated region: DEFAULT/ {
	split($0, a, "[][]");
	tfrom = ((a[2] + 0) > 3072) ? "MORE THAN 3072" : a[2];
	tto = (((a[4] + 0) > 512) && ((a[4] + 0) < 2560)) ? "512 TO 2560 (the relocated ^bigh, minus the freed ^x tail)" : a[4];
	printf "Truncated region: DEFAULT. Reduced total blocks from [%s] to [%s]. Reduced free blocks from [ARBITRARY] to [ARBITRARY].\n", tfrom, tto;
}
