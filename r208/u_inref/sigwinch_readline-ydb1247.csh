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
echo '# [#1247] Test the SIGWINCH deviceparameter at a readline direct mode prompt                                          #'
echo '# Direct mode reads through the readline library when ydb_readline is set, which handles a SIGWINCH differently from  #'
echo '# the plain dm_read path that the sigwinch_devparam-ydb1247 subtest covers: the signal handler longjmps out of        #'
echo '# readline, which saves the partially typed line, drives the handler and then restores the line (see readline.c).     #'
echo '# An expect script resizes the pty of a mumps -direct process (which delivers SIGWINCH) and verifies that:            #'
echo '#   1. a resize while a line is partially typed runs the handler and readline comes back with the line intact         #'
echo '#   2. a valueless SIGWINCH refreshes the device WIDTH/LENGTH without interrupting the readline prompt                #'
echo '#   3. NOSIGWINCH stops the refresh, leaving the dimensions at what the last refresh recorded                         #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

set tname = sigwinch1247rl
# The test framework randomizes ydb_readline, so set it here: this subtest is only about the readline path
setenv ydb_readline 1
# Make sure YottaDB can find the readline library. It only uses readline if it can dlopen it, so without
# this check the subtest would silently degrade into a second copy of the non-readline test.
set readline_found = `/sbin/ldconfig -p |& grep -c "libreadline.so"`
if (0 == $readline_found) then
	echo "TEST-E-NOREADLINE, libreadline not found by ldconfig, so this subtest cannot test the readline path"
endif
cp $gtm_tst/$tst/inref/sigwinch1247.m .
# The expect script below keeps the spawned session quiet (log_user 0) and writes only its own PASS lines.
# That is because readline redraws the prompt and the partially typed line with escape sequences whose exact
# form depends on the terminal, which would make a raw transcript an unstable reference.
(expect -d $gtm_tst/$tst/u_inref/sigwinch_readline-ydb1247.exp > $tname.exp.out) >& $tname.exp.dbg
cat $tname.exp.out
