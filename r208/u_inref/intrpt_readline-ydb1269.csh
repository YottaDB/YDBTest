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

echo "#---------------------------------------------------------------------------------------------------------------------#"
echo '# [YDB#1269] Test MUPIP INTRPT at a readline direct mode prompt                                                       #'
echo '# Direct mode reads through the readline library when ydb_readline is set. A MUPIP INTRPT that arrives while the      #'
echo '# process sits in that read makes the signal handler longjmp out of libreadline; readline_read_mval() then saves the  #'
echo '# partially typed line, drives $ZINTERRUPT and restores the line on the way back in. An interrupt that arrives when   #'
echo '# the process is NOT inside libreadline reaches the same code with nothing to save, and saving libreadline state      #'
echo '# there is what caused the SIGSEGV of YDB#1269. An expect script sends MUPIP INTRPT to a mumps -direct process and    #'
echo '# verifies that:                                                                                                      #'
echo '#   1. an interrupt while a line is partially typed drives $ZINTERRUPT and readline comes back with the line intact   #'
echo '#   2. an interrupt that arrives while a command is executing, i.e. outside libreadline, drives $ZINTERRUPT and       #'
echo '#      leaves the process at a working prompt                                                                         #'
echo '#   3. a burst of interrupts at the prompt leaves the process alive with the prompt still usable                      #'
echo '#   4. an interrupt that is still pending when the process first reaches the direct mode prompt, which is             #'
echo '#      the SIGSEGV of YDB#1269 itself, runs $ZINTERRUPT and leaves the process at a working prompt                    #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

# The test framework randomizes ydb_readline, so set it here: this subtest is only about the readline path
setenv ydb_readline 1
# Make sure YottaDB can find the readline library. It only uses readline if it can dlopen it, so without
# this check the subtest would silently degrade into a test of the plain dm_read path.
set readline_found = `/sbin/ldconfig -p |& grep -c "libreadline.so"`
if (0 == $readline_found) then
	echo "TEST-E-NOREADLINE, libreadline not found by ldconfig, so this subtest cannot test the readline path"
endif
cp $gtm_tst/$tst/inref/intr1269.m .
$gtm_tst/com/dbcreate.csh mumps
# The expect script below keeps the spawned session quiet (log_user 0) and writes only its own PASS lines.
# That is because readline redraws the prompt and the partially typed line with escape sequences whose exact
# form depends on the terminal, which would make a raw transcript an unstable reference.
(expect -d $gtm_tst/$tst/u_inref/intrpt_readline-ydb1269.exp > intrpt1269.exp.out) >& intrpt1269.exp.dbg
cat intrpt1269.exp.out

$gtm_tst/com/dbcheck.csh
