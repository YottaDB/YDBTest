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
#
# C9905-001119 GT.M should handle first-time global reference (with nonzero out-of-date clue) when in final TP retry
#

$gtm_tst/com/dbcreate.csh mumps -blk=512 -glo=64

$GTM << GTM_EOF
	do ^c001119
GTM_EOF

# The 9 jobs can wait long enough on a semaphore to invoke %YDBPROCSTUCKEXEC, whose backgrounded DSE would otherwise
# still have mumps.dat open after this subtest ends (TEST-E-LSOF)
$gtm_tst/com/wait_for_ydbprocstuckexec_jobbed_pids.csh

$gtm_tst/com/dbcheck.csh

echo "End of C9905001119 test..."
