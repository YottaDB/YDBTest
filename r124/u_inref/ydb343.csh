#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Create global ^x with lots of nodes (10000) so a ZWRITE ^x takes a long time and is interruptible"
$ydb_dist/mumps -run ^%XCMD 'for i=1:1:10000 set ^x(i)=i'

echo "# Test that use of a local variable after a Ctrl-C'ed ZWRITE in direct mode does not issue assert failure"
# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/ydb343.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx

# The expect_sanitized.outx contains "zwrite ^x" output that is interrupted. Normally one would see "zwrite ^x"
# followed by a set of lines "^x(...)=..." and then a YDB-I-CTRLC line. But in some cases we found the output
# to contain "zwrite ^x" followed by the "^x(...)=..." section with some missing output. Examples of such output are
#
# ^x(1991)=1991
# 1992)=1992		<-- In this case, "^x(" is missing
# ^x(1993)=1993
#
# ^x(188)=188
# =189			<-- In this case, "^x(189)" is missing
# ^x(190)=190
#
# ^x(30)=30
# =189			<-- In this case, not just "^x(189)" is missing but a lot of lines from "^x(31)=31" to "^x(188)=188"
# ^x(190)=190
#
# All cases of missing output were seen in the ARM platform. Not sure why though.
# Since the purpose of this test is to ensure a YDB-I-CTRLC line shows up, we filter anything that shows up
# between the "zwrite ^x" and "%YDB-I-CTRLC" lines using the ydb343.awk script below.
$tst_awk -f $gtm_tst/$tst/u_inref/ydb343.awk expect_sanitized.outx

echo '# Shut down the DB'
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
