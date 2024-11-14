#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
/* C9H09-002905 Source server should log only AFTER sending at least 10000 transactions on the pipe */

BEGIN	{
	prev=-9999;
	fail=0;
	min=10000;
	ll=0;
}

/^.* : REPL INFO - Seqno/ {
	line[++ll]=$0
	sub(/^.* Seqno : /,"")
	curr=+$0
	delta=curr-prev
	if (min > delta) {
		fail++;
		if (fail==1)
			print "TEST-F-FAIL";
		printf("TEST-E-REPLINFO: Found REPL INFO message in SRC*.log with a gap of at least %d transactions\n", delta);
		printf("TEST-I-REPLINFO: Expected gap between REPL INFO messages is >= %d transactions\n", min);
		print "Previous:\t"line[ll - 1];
		print "Current:\t"line[ll];
	}
	prev=+$0
}

END {
	if (0 == ll) {
		print "TEST-W-WARN    : No messages found. Please check SRC_*.log and amend the test as necessary"
	} else if (0 == fail) {
		printf("TEST-S-REPLINFO: Found REPL INFO message in SRC*.log with a gap of at least ");
		printf("$min (> %d) transactions ; $min = GTM_TEST_DEBUGINFO %d\n", min, delta);
		print "TEST-S-PASS    : Test succeeded"
	}
}
