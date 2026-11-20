#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The source server logs a REPL INFO line for the first batch of transactions that the source server sends
# after connecting to the receiver server, and from then on once at least 10000 transactions (the default
# log interval) were sent since the last REPL INFO line. The seqno of the first line depends on how many of the
# 50000 transactions were already done when the receiver server connected, so the check below is on the
# difference between the seqnos of consecutive lines and not on the seqnos.
#
# The source server sends transactions in batches, so the difference can be more than 10000. From GT.M
# V7.1-003 onwards (most likely due to GTM-F228991), differences of up to 11500 have been observed when the
# source server reads from the journal files (instead of the journal pool), so up to 12000 is a PASS.
BEGIN	{
	total = 50000
	min_interval = 10000
	max_interval = 12000
	fail = 0
	print "# Validate that consecutive REPL INFO lines in the source server log are " min_interval " to " max_interval " transactions apart"
}
{
	seqno[NR] = $6
	if (1 == NR) {
		if ((seqno[NR] < 1) || (seqno[NR] > total)) {
			printf "FAIL : Seqno [%d] of line 1 is not in the range [1,%d]\n", seqno[NR], total
			fail = 1
		}
	} else {
		diff = seqno[NR] - seqno[NR - 1]
		if ((diff < min_interval) || (diff > max_interval)) {
			printf "FAIL : Seqno [%d] of line %d is %d more than Seqno [%d] of line %d\n", seqno[NR], NR, diff, seqno[NR - 1], NR - 1
			fail = 1
		}
	}
}
END {
	if (0 == NR) {
		print "FAIL : No REPL INFO line found in the source server log"
		fail = 1
	} else if ((total - seqno[NR]) >= max_interval) {
		# At least one more REPL INFO line should have been logged after the last one
		printf "FAIL : Seqno [%d] of the last line (line %d) is %d or more less than the %d transactions that were done\n", seqno[NR], NR, max_interval, total
		fail = 1
	}
	if (fail) {
		for (i = 1; i <= NR; i++) printf "Line %d : Seqno [%d]\n", i, seqno[i]
	} else
		print "PASS : every REPL INFO line is " min_interval " to " max_interval " transactions after the previous one"
}
