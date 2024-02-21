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

echo "# gtm_non_blocked_write_retries: 22"
setenv gtm_non_blocked_write_retries 22
echo "# ydb_non_blocked_write_retries: not set"
unsetenv ydb_non_blocked_write_retries
($gtm_dist/mumps -run srv22^gtm8843 $portno >& server.out &)
strace --trace=sendto $gtm_dist/mumps -run cli22^gtm8843 $portno >& strace.out
echo -n "result: "
cat strace.out | grep EAGAIN | wc -l

$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill2.out
$gtm_tst/com/dbcheck.csh >& dbcheck.log
$gtm_tst/com/portno_release.csh

sed -i '/\(testarea\|FORCEDHALT\)/d' server.out