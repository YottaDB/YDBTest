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
$gtm_dist/mumps -run procCleanupPrepare^gtm8843 $portno >& kill0.out

echo "# gtm_non_blocked_write_retries: 10 (not set, default)"
unsetenv gtm_non_blocked_write_retries
echo "# ydb_non_blocked_write_retries: 10 (not set, default)"
unsetenv ydb_non_blocked_write_retries
source $gtm_tst/com/portno_acquire.csh >& portno1.out
($gtm_dist/mumps -run srv13^gtm8843 $portno >& server1.out &)
strace --trace=sendto $gtm_dist/mumps -run cli13^gtm8843 $portno >& strace1.out
echo -n "result: "
cat strace1.out | grep EAGAIN | wc -l
$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill1.out
$gtm_tst/com/portno_release.csh

echo "# gtm_non_blocked_write_retries: 22"
setenv gtm_non_blocked_write_retries 22
echo "# ydb_non_blocked_write_retries: not set"
unsetenv ydb_non_blocked_write_retries
source $gtm_tst/com/portno_acquire.csh >& portno2.out
($gtm_dist/mumps -run srv13^gtm8843 $portno >& server2.out &)
strace --trace=sendto $gtm_dist/mumps -run cli13^gtm8843 $portno >& strace2.out
echo -n "result: "
cat strace2.out | grep EAGAIN | wc -l
$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill2.out
$gtm_tst/com/portno_release.csh

echo "# gtm_non_blocked_write_retries: not set"
unsetenv gtm_non_blocked_write_retries
echo "# ydb_non_blocked_write_retries: 14"
setenv ydb_non_blocked_write_retries 14
source $gtm_tst/com/portno_acquire.csh >& portno3.out
($gtm_dist/mumps -run srv13^gtm8843 $portno >& server3.out &)
strace --trace=sendto $gtm_dist/mumps -run cli13^gtm8843 $portno >& strace3.out
echo -n "result: "
cat strace3.out | grep EAGAIN | wc -l
$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill3.out
$gtm_tst/com/portno_release.csh

($gtm_tst/com/dbcheck.csh >& dbcheck.log)

sed -i '/\(testarea\|FORCEDHALT\)/d' server1.out
sed -i '/\(testarea\|FORCEDHALT\)/d' server2.out
sed -i '/\(testarea\|FORCEDHALT\)/d' server3.out
