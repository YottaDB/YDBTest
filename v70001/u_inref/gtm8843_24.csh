#!/usr/local/bin/tcsh -f
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

source $gtm_tst/com/portno_acquire.csh >& portno.out
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
$gtm_dist/mumps -run procCleanupPrepare^gtm8843 $portno >& kill1.out

echo "# gtm_non_blocked_write_retries: 25"
setenv gtm_non_blocked_write_retries 25
echo "# ydb_non_blocked_write_retries: not set"
unsetenv ydb_non_blocked_write_retries
($gtm_dist/mumps -run cli14^gtm8843 $portno >& client.out &)
strace -o trace.outx $gtm_dist/mumps -run srv14^gtm8843 $portno
echo -n "result: "
# Count "send" and "sendto" system calls with EAGAIN result
grep "^send.*EAGAIN" trace.outx | wc -l

$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill2.out
$gtm_tst/com/dbcheck.csh >& dbcheck.log
$gtm_tst/com/portno_release.csh

sed -i '/\(testarea\|FORCEDHALT\)/d' client.out
