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


echo "#-------------------------------------------------------------------------------------------------------------------#"
echo '# [YDB#1295] Test the readline history file is kept to 1000 entries even if history_truncate_file() fails           #'
echo '# At exit, a process that used readline appends its history to the history file and calls history_truncate_file()   #'
echo '# of the readline library to keep the file to 1000 entries. In some readline builds that function always fails      #'
echo '# without trimming the file, which then grows without limit. YottaDB now does the truncation itself when that       #'
echo '# happens. White box test case 411 (WBTEST_YDB_READLINE_TRUNCFAIL) makes YottaDB behave as if the function failed.  #'
echo '# Each step starts from a history file of 3000 entries, "write 1" to "write 3000". This subtest verifies that:      #'
echo '#   1. a direct mode session leaves the file with the last 1000 entries (this exercises the YottaDB fallback only   #'
echo '#      on systems whose readline library has the failing history_truncate_file())                                   #'
echo '#   2. the same, with the failure forced by the white box test case, so the YottaDB fallback does the truncation    #'
echo '#   3. the same, with a second session that starts and exits while the first one is at its prompt: the file keeps   #'
echo '#      the entries the second session added                                                                         #'
echo "#-------------------------------------------------------------------------------------------------------------------#"
echo

# The test framework randomizes ydb_readline, so set it here: this subtest is only about the readline path
setenv ydb_readline 1
# Make sure YottaDB can find the readline library. It only uses readline if it can dlopen it, so without
# this check every step would fail for a reason that has nothing to do with what it tests.
set readline_found = `/sbin/ldconfig -p |& grep -c "libreadline.so"`
if (0 == $readline_found) then
	echo "TEST-E-NOREADLINE, libreadline not found by ldconfig, so this subtest cannot test the readline path"
endif
# Every step runs with HOME pointing to a directory of its own that starts with a 3000 entry history file
foreach step (1 2 3)
	mkdir home$step
	seq 1 3000 | $tst_awk '{print "write " $1}' > home$step/.ydb_YottaDB_history
end
# The checks are done by readline_histcheck-ydb1295.csh, which prints PASS or WRONG
set check = "$gtm_tst/$tst/u_inref/readline_histcheck-ydb1295.csh"
set expscript = "$gtm_tst/$tst/u_inref/readline_truncate_fallback-ydb1295.exp"

echo
echo '# Step 1 : from a terminal, HOME=home1 $gtm_dist/yottadb -direct, then'
echo '#          YDB>write "O","NE",!'
echo '#          YDB>halt'
echo '#          expect ONE, and home1/.ydb_YottaDB_history to hold 1000 entries: "write 2003" to "write 3000",'
echo '#          then the 2 lines typed at the prompt'
(env HOME=$PWD/home1 expect -d $expscript single > step1.exp.out) >& step1.exp.dbg
cat step1.exp.out
$check home1/.ydb_YottaDB_history 1000 "write 2003" "halt"

echo
echo '# Step 2 : the same as step 1 with HOME=home2, and with white box test case 411 enabled'
echo '#          expect the same, now from the YottaDB fallback'
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 411
(env HOME=$PWD/home2 expect -d $expscript single > step2.exp.out) >& step2.exp.dbg
cat step2.exp.out
$check home2/.ydb_YottaDB_history 1000 "write 2003" "halt"

echo
echo '# Step 3 : with white box test case 411 still enabled, from terminal A, HOME=home3 $gtm_dist/yottadb -direct'
echo '#          then, from terminal B, HOME=home3 $gtm_dist/yottadb -direct, then'
echo '#          YDB>write "B","EE",!'
echo '#          YDB>halt'
echo '#          then, at the prompt of terminal A,'
echo '#          YDB>write "A","AA",!'
echo '#          YDB>halt'
echo '#          expect BEE and AAA, and home3/.ydb_YottaDB_history to hold 1000 entries: "write 2005" to "write 3000",'
echo '#          then the 2 lines typed in terminal B, then the 2 lines typed in terminal A'
(env HOME=$PWD/home3 expect -d $expscript concurrent > step3.exp.out) >& step3.exp.dbg
cat step3.exp.out
$check home3/.ydb_YottaDB_history 1000 "write 2005" "halt" 'write "B","EE",!'
# Setting the enable variable to 0 would leave white box testing on, since only its presence is checked
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
