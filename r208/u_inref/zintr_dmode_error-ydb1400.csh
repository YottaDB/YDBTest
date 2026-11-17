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
echo "#-------------------------------------------------------------------------------------------------------------#"
echo '# [YDB#1400] An error in or after $ZINTERRUPT or $ZTIMEOUT code that interrupts a direct mode READ from a      #'
echo '# device that is not a terminal drives $ETRAP or $ZTRAP                                                       #'
echo "#-------------------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs drive^ydb1400, which starts child^ydb1400 with a PIPE device as the principal device of the'
echo '# child. The child sets $ZTRAP (or $ETRAP) to code that writes the error and halts, sets $ZINTERRUPT (or'
echo '# $ZTIMEOUT), and does a BREAK. Direct mode in the child then reads commands from the PIPE. The driver waits'
echo '# for the direct mode prompt, sends the child a MUPIP INTRPT (stage 4 has a 2 second $ZTIMEOUT instead), and'
echo '# writes each line of the output of the child after "child : ". The prompt is taken out of that output.'
echo

# The driver recognizes the direct mode prompt of the child by this text
unsetenv ydb_prompt
setenv gtm_prompt "DMPROMPT>"
cp $gtm_tst/$tst/inref/ydb1400.m .
foreach stage (1 2 3 4 5)
	switch ($stage)
	case 1:
		echo '# Stage 1 : $ZINTERRUPT code calls a routine that divides by zero, with $ZTRAP set'
		set setup = 'set $zinterrupt="do err^ydb1400"'
		set expect = ('in err^ydb1400' '$ZTRAP code ran, error is DIVZERO')
		breaksw
	case 2:
		echo '# Stage 2 : $ZINTERRUPT code calls a routine that divides by zero, with $ETRAP set'
		set setup = 'set $zinterrupt="do err^ydb1400"'
		set expect = ('in err^ydb1400' '$ETRAP code ran, error is DIVZERO')
		breaksw
	case 3:
		echo '# Stage 3 : $ZINTERRUPT code leaves with a ZGOTO to level 1, where the routine divides by zero'
		set setup = 'set $zinterrupt="zgoto 1:after^ydb1400"'
		set expect = ('at after^ydb1400' '$ZTRAP code ran, error is DIVZERO')
		breaksw
	case 4:
		echo '# Stage 4 : $ZTIMEOUT code calls a routine that divides by zero, with $ZTRAP set'
		set setup = 'set $ztimeout="2:do err^ydb1400"'
		set expect = ('in err^ydb1400' '$ZTRAP code ran, error is DIVZERO')
		breaksw
	case 5:
		echo '# Stage 5 : $ZINTERRUPT code itself divides by zero. Direct mode reports the error and prompts again'
		set setup = 'set $zinterrupt="write 1/0"'
		set expect = ('DIVZERO' 'ERRWZINTR' 'typed command ran')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run drive^ydb1400 '"$stage, where the child does : $setup"
	if (5 == $stage) then
		echo '# Before the fix : the same result'
		echo '# With the fix   : expect DIVZERO and ERRWZINTR from direct mode, then "typed command ran" from the'
		echo '#                  command sent to the next prompt'
	else
		echo '# Before the fix : the trap code did not run. A Release build ended with GTMASSERT2 and a Debug build'
		echo '#                  failed an assert, both in trans_code_cleanup.c'
		echo "# With the fix   : expect the child to write [$expect[1]] and then [$expect[2]]"
	endif
	$gtm_dist/mumps -run drive^ydb1400 $stage >& stage$stage.out
	cat stage$stage.out
	set verdict = "PASS"
	foreach line ($expect:q)
		if (1 != `$grep -c -- "$line" stage$stage.out`) set verdict = "FAIL"
	end
	if (`$grep -c -- "-F-" stage$stage.out`) set verdict = "FAIL"
	if (5 != $stage) then
		# The error must reach the trap code, not direct mode, so the output has no error message
		if (`$grep -c -- "-E-" stage$stage.out`) set verdict = "FAIL"
	endif
	echo "$verdict : stage $stage"
	if (5 == $stage) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out "DIVZERO" "ERRWZINTR" >& stage${stage}_check_error_exist.logx
	endif
	echo
end
