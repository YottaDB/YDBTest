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

echo "#--------------------------------------------------------------------------------------------------#"
echo '# [YDB#1258] A journal record time must never be behind a $HOROLOG read that preceded the update   #'
echo "#--------------------------------------------------------------------------------------------------#"
echo

# Journal record timestamps used to come from time(), while $HOROLOG, $ZHOROLOG, $ZUT and HANG come from
# clock_gettime(CLOCK_REALTIME). On Linux both are served from the vDSO with no system call; what differs is
# what they read. time() returns a seconds value the kernel refreshes once per timekeeping tick, so for a
# short window after every second boundary it still reports the previous second. That window was measured at up to 1.68 milliseconds on one system and 1.52 on another.
#
# ydb1258.m puts every $HOROLOG read inside that window on purpose, by spinning until the microsecond field
# of $ZHOROLOG is small. That is what makes this deterministic, where rollback_A/full_qual reaches the window
# only by chance and so fails on rare occasions, at roughly 1.6 runs in 1000.
#
# On a build carrying the defect this subtest reports WRONG for nearly every record. On a fixed build both
# assertions hold by construction rather than by luck: the journal time is read strictly after the $HOROLOG
# it is compared against, from the same non decreasing clock, so it can never be lower; and HANG 1 sleeps on
# that same clock until it has passed, so the second must have advanced.
#
# The spin in ydb1258.m is bounded by $ZUT and cannot hang. A build too slow to land in the window loses
# detection, never a false failure. The update stage takes about 16 seconds, since each of the 13 samples
# waits for a fresh second boundary.

# Before-image journaling requires BG, so do not let the test system pick MM
source $gtm_tst/com/gtm_test_setbgaccess.csh
# This subtest wants a single region and a known journal state, so keep the test system from randomly
# spanning regions or turning journaling on behind us. Journaling is turned on explicitly below.
setenv gtm_test_spanreg 0
setenv gtm_test_jnl NON_SETJNL

$gtm_tst/com/dbcreate.csh mumps

echo '# Command : $MUPIP set -journal=enable,on,before -region "*"'
$MUPIP set -journal=enable,on,before -region "*" >&! jnlon.log
if (0 == $status) then
	echo "PASS : journaling is enabled"
else
	echo "WRONG : could not enable journaling - see jnlon.log"
	cat jnlon.log
endif
echo

echo '# Stage 1 : record $HOROLOG just past a second boundary, then update a global.'
echo '#           ^x(1) to ^x(10) are updated with nothing in between, ^y(1) to ^y(3) with a HANG 1,'
echo '#           which is the shape rollback_A/full_qual uses.'
echo '# Command : $ydb_dist/mumps -run update^ydb1258'
$gtm_dist/mumps -run update^ydb1258 >&! update.log
if (0 == $status) then
	echo "PASS : the update program completed"
else
	echo "WRONG : the update program failed - see update.log"
	cat update.log
endif
echo

echo '# Command : $MUPIP journal -extract=jnlext.mjf -forward mumps.mjl'
$MUPIP journal -extract=jnlext.mjf -forward mumps.mjl >&! jnlext.log
if (0 == $status) then
	echo "PASS : the journal extract succeeded"
else
	echo "WRONG : the journal extract failed - see jnlext.log"
	cat jnlext.log
endif
echo

echo '# Stage 2 : compare each journal record time against the $HOROLOG recorded before that update.'
echo '#           ^x records must not be BEHIND it. ^y records must be strictly LATER, since a whole'
echo '#           second was spent in HANG 1 before the update.'
echo '# Command : $ydb_dist/mumps -run check^ydb1258'
$gtm_dist/mumps -run check^ydb1258
echo

echo "# Done"

$gtm_tst/com/dbcheck.csh
