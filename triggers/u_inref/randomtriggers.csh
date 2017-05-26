#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Since this test creates random set of trigger definitions and loads them, it is possible some of those
# give assert failures (during trigger load) in pre-V62000 versions of GT.M (which is used by the on-the-fly
# trigger upgrade test). It is not easy to avoid those patterns since this is a random test.
# Hence disable on-the-fly trigger upgrade testing in this subtest.
unsetenv gtm_test_trig_upgrade

$gtm_tst/com/dbcreate.csh mumps 4

$gtm_tst/com/backup_dbjnl.csh "bak1" "*.dat"

echo "Generating random set of triggers  : mumps -run randomtriggers               >& trigfile.trg"
$gtm_exe/mumps -run randomtriggers >& trigfile.trg
echo "Running MUPIP TRIGGER -TRIGGERFILE : mupip trigger -triggerfile=trigfile.trg >& trigfile.log"
$MUPIP trigger -noprompt -trigger=trigfile.trg |& $grep -v FROZEN > trigfile.log
echo "Running MUPIP TRIGGER -SELECT      : mupip trigger -select                   >& trigfile.select.log"
$MUPIP trigger -select trigfile.select.log
echo "Computing expected MUPIP TRIGGER -TRIGGERFILE (in trigfile.cmp) and MUPIP TRIGGER -SELECT (in trigfile.select.cmp) output"
echo "    --> Running : mumps -run gentrigload^randomtriggers trigfile.trg trigfile.cmp trigfile.select.cmp"
$gtm_exe/mumps -run gentrigload^randomtriggers trigfile.trg trigfile.cmp trigfile.select.cmp
echo "diff trigfile.cmp trigfile.log"
diff trigfile.cmp trigfile.log >& trigfile.diff
if (! $status) then
	echo "Verification of MUPIP TRIGGER -TRIGGERFILE output : PASSED"
else
	echo "Verification of MUPIP TRIGGER -TRIGGERFILE output : FAILED. trigfile.diff output follows"
	cat trigfile.diff
endif
echo "Sorting MUPIP TRIGGER -SELECT output before diff"
sort trigfile.select.cmp > trigfile.select.cmp.sort
sort trigfile.select.log > trigfile.select.log.sort

echo "diff trigfile.select.cmp.sort trigfile.select.log.sort"
diff trigfile.select.cmp.sort trigfile.select.log.sort >& trigfile.select.sort.diff
if (! $status) then
	echo "Verification of MUPIP TRIGGER -SELECT output : PASSED"
else
	echo "Verification of MUPIP TRIGGER -SELECT output : FAILED. trigfile.select.sort.diff output follows"
	cat trigfile.select.sort.diff
endif

echo "Checking database integs clean"
$gtm_tst/com/dbcheck.csh

$gtm_tst/com/backup_dbjnl.csh "bak2" "*.dat" mv

echo "Recreating database"
$gtm_tst/com/dbcreate.csh mumps 4

echo "Reloading triggers from MUPIP TRIGGER -SELECT output : mupip trigger -triggerfile=trigfile.select.cmp"
$MUPIP trigger -noprompt -triggerfile=trigfile.select.cmp >& trigfile.reload.log2
echo "Selecting triggers from reloaded database : mupip trigger -select trigfile.reload.select.log"
$MUPIP trigger -select trigfile.reload.select.log2
$grep -v '^;trigger name' trigfile.select.cmp > trigfile.reload.select.cmp
$grep -v '^;trigger name' trigfile.reload.select.log2 > trigfile.reload.select.log
# It is possible that on a reload of the triggers, SET and KILL triggers get merged into one
# But that would show up in the diff. To avoid that split SET and KILL triggers into separate ones
# for the purposes of the diff. We use trigsplit^randomtriggers for this purpose.
$gtm_exe/mumps -run trigsplit^randomtriggers trigfile.reload.select.cmp | sort >& trigfile.reload.cmp
$gtm_exe/mumps -run trigsplit^randomtriggers trigfile.reload.select.log | sort >& trigfile.reload.log
echo "Comparing trigger select output from the reloaded database with that of originally loaded database"
echo "diff trigfile.reload.cmp trigfile.reload.log"
diff trigfile.reload.cmp trigfile.reload.log >& trigfile.reload.diff
if (! $status) then
	echo "Verification of RELOAD of MUPIP TRIGGER -SELECT output : PASSED"
else
	echo "Verification of RELOAD of MUPIP TRIGGER -SELECT output : FAILED. trigfile.reload.diff output follows"
	cat trigfile.reload.diff
endif
echo "Checking reloaded database integs clean"
$gtm_tst/com/dbcheck.csh
