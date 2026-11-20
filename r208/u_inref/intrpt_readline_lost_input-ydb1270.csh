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
echo '# [YDB#1270] Test MUPIP INTRPT and other signals do not lose input typed at a readline direct mode prompt             #'
echo '# Direct mode reads through the readline library when ydb_readline is set. Stages 1 to 8 run mumps -direct under      #'
echo '# gdb, stop the process at a chosen point inside libreadline while a typed line is being read, deliver a signal at    #'
echo '# that point and verify that the typed line still runs as typed, that the process does not terminate and that the     #'
echo '# signal was acted on ($ZINTERRUPT for SIGUSR1, the SIGWINCH action for SIGWINCH). The points are                     #'
echo '#   1. the entry of rl_insert(), where libreadline has read the first character of the line but not yet stored it     #'
echo '#   2. the entry of rl_deprep_terminal(), where libreadline has processed the <CR> but not yet returned the line      #'
echo '#   3. the 5th entry of rl_insert(), for a character in the middle of the line                                        #'
echo '#   4. the entry of rl_newline(), where libreadline has read the <CR> but not yet acted on it                         #'
echo '#   5. rl_free_undo_list() after the undo list of the line is freed but before rl_undo_list is cleared                #'
echo '#   6. rl_set_prompt() at the second prompt, after the previous prompt is freed but before rl_prompt is set           #'
echo '#   7. the entry of rl_insert() with SIGINT, where the CTRLC message must follow the output of the line               #'
echo '#   8. the entry of rl_insert() with SIGWINCH, after a SIGWINCH action is set up                                      #'
echo '# Stage 9 runs mumps -direct without gdb and sends a MUPIP INTRPT between the bytes of the up arrow key.              #'
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
# $ZINTERRUPT counts its invocations in a local variable. The expect script reads the count to tell that
# the signal was delivered and handled, i.e. that the stage did test what the stage says it tests.
setenv gtm_zinterrupt 'set zintcnt=$get(zintcnt,0)+1'
# The leak check of an ASAN build does not work for a process that runs under gdb
if ($?ASAN_OPTIONS) then
	setenv ASAN_OPTIONS "${ASAN_OPTIONS}:detect_leaks=0"
else
	setenv ASAN_OPTIONS "detect_leaks=0"
endif

# One gdb command file for each gdb stage. "run" returns when the process stops at the first breakpoint.
# "queue-signal" then has gdb deliver the signal to the process at that exact point when "continue" resumes the process.
cat > gdb_header.cmd << CAT_EOF
set pagination off
set breakpoint pending on
handle SIGUSR1 nostop noprint pass
handle SIGALRM nostop noprint pass
handle SIGWINCH nostop noprint pass
handle SIGINT nostop noprint pass
CAT_EOF
# Stages 1 and 2 : stop at the entry of the function
foreach func (rl_insert rl_deprep_terminal)
	cp gdb_header.cmd gdb_$func.cmd
	printf "tbreak $func\nrun -direct\nqueue-signal SIGUSR1\ncontinue\n" >> gdb_$func.cmd
end
# Stage 3 : stop at the 5th entry of rl_insert() ("ignore" skips the first 4)
cp gdb_header.cmd gdb_rl_insert_5th.cmd
printf "break rl_insert\nignore 1 4\nrun -direct\ndelete\nqueue-signal SIGUSR1\ncontinue\n" >> gdb_rl_insert_5th.cmd
# Stage 4 : stop at the entry of rl_newline()
cp gdb_header.cmd gdb_rl_newline.cmd
printf "tbreak rl_newline\nrun -direct\nqueue-signal SIGUSR1\ncontinue\n" >> gdb_rl_newline.cmd
# Stage 5 : stop at the entry of _rl_free_undo_list() and "finish" it, which stops in rl_free_undo_list() before
# rl_free_undo_list() clears rl_undo_list
cp gdb_header.cmd gdb_undo_list.cmd
printf "tbreak _rl_free_undo_list\nrun -direct\nfinish\nqueue-signal SIGUSR1\ncontinue\n" >> gdb_undo_list.cmd
# Stage 6 : stop at the second entry of rl_set_prompt(), then at the free() of the previous prompt, and "finish" the
# free(), which stops in rl_set_prompt() before rl_set_prompt() sets rl_prompt
cp gdb_header.cmd gdb_set_prompt.cmd
printf "break rl_set_prompt\nignore 1 1\nrun -direct\ndelete\ntbreak free\ncontinue\nfinish\nqueue-signal SIGUSR1\ncontinue\n" >> gdb_set_prompt.cmd
# Stage 7 : SIGINT at the entry of rl_insert()
cp gdb_header.cmd gdb_rl_insert_sigint.cmd
printf "tbreak rl_insert\nrun -direct\nqueue-signal SIGINT\ncontinue\n" >> gdb_rl_insert_sigint.cmd
# Stage 8 : SIGWINCH at the entry of rl_insert() for the line after the first <CR>, i.e. after the line that sets up
# the SIGWINCH action
cp gdb_header.cmd gdb_rl_insert_sigwinch.cmd
printf "tbreak rl_newline\nrun -direct\ntbreak rl_insert\ncontinue\nqueue-signal SIGWINCH\ncontinue\n" >> gdb_rl_insert_sigwinch.cmd

# The expect script below keeps the spawned session quiet (log_user 0) and writes only its own PASS/FAIL lines.
# That is because readline redraws the prompt and the typed line with escape sequences whose exact
# form depends on the terminal, which would make a raw transcript an unstable reference.
(expect -d $gtm_tst/$tst/u_inref/intrpt_readline_lost_input-ydb1270.exp > intrpt1270.exp.out) >& intrpt1270.exp.dbg
cat intrpt1270.exp.out
