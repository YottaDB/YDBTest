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

BEGIN	{
	print "# Validate that the sequence numbers in REPL INFO messages are approximately 10000 transactions apart."
	print "# From GT.M V7.1-003 onwards (due most likely to GTM-F228991), these numbers have been observed to be as"
	print "# much as 11500 apart when the source server reads from the journal file (instead of the journal pool)."
	print "# We treat up to 12000 apart difference to be a PASS and anything more to be a FAIL below ."
}
{
	seqno=$6; line_no=(NR-1)
	min_interval = 10000
	max_interval = 12000
	max_allowed = ((line_no * max_interval) + (max_interval - min_interval))
	min_allowed = (line_no * min_interval)
	if ((seqno > min_allowed) && (seqno < max_allowed)) {
		printf "Seqno [%d] in expected range [%d,%d]\n", seqno, min_allowed, max_allowed
	} else {
		printf "Seqno [%d] out of expected range [%d,%d]\n", seqno, min_allowed, max_allowed
	}
}
END {
	if (NR != 5) { printf "TEST-E-FAIL : Saw %d lines of output, but expected exactly 5", NR; }
}
