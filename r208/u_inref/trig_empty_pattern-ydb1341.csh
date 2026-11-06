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
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1341] $ZTRIGGER() and MUPIP TRIGGER reject a trigger subscript pattern that is empty or       #'
echo '# not valid, instead of loading it and then failing every SET of the global with PATCODE             #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# The trigger definition parser checked each pattern code after the ? of a pattern subscript, so it'
echo '# accepted a ? with no pattern codes after it, and an empty alternation. When the trigger was used,'
echo '# the pattern compiler rejected it, so every SET of the global failed with PATCODE until the trigger'
echo '# was deleted, and a Debug build failed an assert in gv_trigger.c (0 < len) for an empty pattern.'
echo '# The parser now also compiles the pattern the way the trigger code does when the trigger is used.'
echo '#'
echo '# Stages 1 to 5 each delete all triggers, load a trigger on ^x with a pattern subscript and the code'
echo '# set ^y=$get(^y)+1, then SET ^x(1), ^x("a"), ^x("bc") and ^x("de"), and check the number of times'
echo '# the trigger ran. Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1341.m .
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : +^x(?)'
echo '# Command : $gtm_dist/mumps -run empty^ydb1341'
echo '# Before the fix : the trigger loaded, and each SET issued PATCODE in a Release build. In a Debug'
echo '#                  build, the first SET failed an assert in gv_trigger.c'
echo '# With the fix   : expect "Missing pattern code after ?", $ZTRIGGER() to return 0, and the SETs'
echo '#                  to succeed'
$gtm_dist/mumps -run empty^ydb1341
echo

echo '# Stage 2 : +^x(?;1)'
echo '# Command : $gtm_dist/mumps -run emptysemi^ydb1341'
echo '# Before the fix : the same failures as in stage 1'
echo '# With the fix   : expect "Missing pattern code after ?", $ZTRIGGER() to return 0, and the SETs'
echo '#                  to succeed'
$gtm_dist/mumps -run emptysemi^ydb1341
echo

echo '# Stage 3 : +^x(?1())'
echo '# Command : $gtm_dist/mumps -run emptyalt^ydb1341'
echo '# Before the fix : the trigger loaded, and each SET issued PATCODE'
echo '# With the fix   : expect "Invalid pattern code", $ZTRIGGER() to return 0, and the SETs to succeed'
$gtm_dist/mumps -run emptyalt^ydb1341
echo

echo '# Stage 4 : +^x(?1(,))'
echo '# Command : $gtm_dist/mumps -run emptyalt2^ydb1341'
echo '# Before the fix : the trigger loaded, and each SET issued PATCODE'
echo '# With the fix   : expect "Invalid pattern code", $ZTRIGGER() to return 0, and the SETs to succeed'
$gtm_dist/mumps -run emptyalt2^ydb1341
echo

echo '# Stage 5 : valid patterns +^x(?1N;?1A), +^x(?1(1"a",1"bc")) and +^x(?.E), one at a time'
echo '# Command : $gtm_dist/mumps -run valid^ydb1341'
echo '# Before the fix : the same as with the fix'
echo '# With the fix   : expect each trigger to load, and to run for 2, 2 and 4 of the SETs'
$gtm_dist/mumps -run valid^ydb1341
echo

echo '# Stage 6 : MUPIP TRIGGER with a trigger file that has the 4 patterns of stages 1 to 4'
echo '# Command : $gtm_dist/mumps -run trgfile^ydb1341, then'
echo '#           $gtm_dist/mupip trigger -triggerfile=badpat.trg -noprompt'
echo '# Before the fix : all 4 entries loaded, and the exit status was 0'
echo '# With the fix   : expect an error for each entry, MUNOACTION, and an exit status that is not 0'
$gtm_dist/mumps -run trgfile^ydb1341
$gtm_dist/mupip trigger -triggerfile=badpat.trg -noprompt >& mupip.out
set stat = $status
echo "# MUPIP TRIGGER exit status is not 0 : `test 0 != $stat && echo PASS || echo FAIL $stat`"
$gtm_tst/com/check_error_exist.csh mupip.out MUNOACTION
echo '# mupip.out (renamed to mupip.outx by check_error_exist.csh), without the MUNOACTION line :'
grep -v MUNOACTION mupip.outx
echo

echo '# Stage 7 : $ZTRIGGER("SELECT")'
echo '# Before the fix : $ZTRIGGER("SELECT") also showed the 4 triggers that stage 6 loaded'
echo '# With the fix   : expect only the trigger left by stage 5 (+^x(?.E), stored as +^x(*))'
echo '# Command : $gtm_dist/mumps -run %XCMD '"'"'if $ztrigger("select")'"'"
$gtm_dist/mumps -run %XCMD 'if $ztrigger("select")'
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
