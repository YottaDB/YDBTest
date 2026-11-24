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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-10623 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410623)

GT.M inhibits epoch tapering when epoch tapering is enabled and only one process actively does updates. Previously, in this situation, epoch tapering could reduce performance. (GTM-10623)

CAT_EOF
echo

echo '# Epoch tapering happens in the last quarter of each epoch interval, with before-image journaling. While a process'
echo '# tapers, the epoch_taper_start_dbuffs field of the shared memory of the region is not zero. V7.1-004 added the'
echo '# epoch_taper_last_pid field (the process that last ran the epoch tapering code), and a process skips the epoch'
echo '# tapering code if that field is the process itself. This subtest uses an EPOCH_INTERVAL of 10 seconds and'
echo '# samples both fields with %PEEKBYNAME for 25 seconds (at least two epochs) while updaters run.'
echo

# Epoch tapering needs BG and before-image journaling
setenv acc_meth BG
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
$MUPIP set -journal=enable,on,before,epoch_interval=10 -region DEFAULT >& jnl_on.out
$MUPIP set -epochtaper -region DEFAULT >& epochtaper.out

echo '# Stage 1 : one updater'
echo '# Before the fix : the updater tapered, so some samples had a non-zero epoch_taper_start_dbuffs'
echo '# With the fix   : expect zero such samples, and 1 process seen in epoch_taper_last_pid'
($gtm_dist/mumps -run updater^gtm10623 >& updater1.out &) >& /dev/null
$gtm_dist/mumps -run sample^gtm10623 25
$gtm_dist/mumps -run %XCMD 'for i=1:1:600 quit:$$^%PEEKBYNAME("node_local.ref_cnt","DEFAULT")<2  hang 0.1'
$gtm_dist/mumps -run %XCMD 'kill ^stop,^pid,^a'
echo

echo '# Stage 2 (a control) : two updaters. Each one tapers after the other one did.'
echo '# Expect more than zero samples with a non-zero epoch_taper_start_dbuffs, and 2 processes in epoch_taper_last_pid'
($gtm_dist/mumps -run updater^gtm10623 >& updater2a.out &) >& /dev/null
($gtm_dist/mumps -run updater^gtm10623 >& updater2b.out &) >& /dev/null
$gtm_dist/mumps -run sample^gtm10623 25
$gtm_dist/mumps -run %XCMD 'for i=1:1:600 quit:$$^%PEEKBYNAME("node_local.ref_cnt","DEFAULT")<2  hang 0.1'
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
