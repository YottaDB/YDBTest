#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
{
	seqno=$3; line_no=(NR-1)
	if (seqno > line_no*10000 && seqno < line_no*10000 + 500) {
		printf "Seqno : %d0xxx\n", line_no
	} else {
		printf "Seqno out of range : %d\n", seqno
	}
}
END {
	if (NR != 5) { print "TEST-E-FAIL : Saw more than 5 lines of output"; }
}
