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
echo '# [YDB#1294] Test a process loads the readline history file only when it reads from a terminal through readline     #'
echo '# With ydb_readline=1, a process used to dlopen libreadline and load (creating it if needed) its history file at    #'
echo '# startup, even when it could never use readline, e.g. with its input from a file or pipe, or a "yottadb -run" that #'
echo '# never enters direct mode. That took time in proportion to the size of the file, and issued a READLINEFILEPERM     #'
echo '# warning when the file could not be created. The history file is now loaded just before the first read through     #'
echo '# readline, i.e. at the first direct mode or DSE/LKE/MUPIP prompt on a terminal. This subtest verifies that:        #'
echo '#   1. yottadb -run with input from /dev/null does not create the history file                                      #'
echo '#   2. yottadb -direct with input from a pipe does not create the history file                                      #'
echo '#   3. LKE, DSE and MUPIP with input from a pipe do not create their history files                                  #'
echo '#   4. yottadb -run with input from /dev/null and an unwritable HOME issues no READLINEFILEPERM warning             #'
echo '#   5. yottadb -run from a terminal, that never enters direct mode, does not create the history file                #'
echo '#   6. yottadb -direct from a terminal creates the history file and saves the line typed at the prompt              #'
echo '#   7. LKE from a terminal creates its history file and saves the command typed at the prompt                       #'
echo '#   8. A call-in whose M code enters direct mode from a terminal does not create the history file, since a        #'
echo '#      call-in never uses readline                                                                                  #'
echo "#-------------------------------------------------------------------------------------------------------------------#"
echo

# The test framework randomizes ydb_readline, so set it here: this subtest is only about the readline path
setenv ydb_readline 1
# Make sure YottaDB can find the readline library. It only uses readline if it can dlopen it, so without
# this check steps 6 and 7 would fail for a reason that has nothing to do with what they test.
set readline_found = `/sbin/ldconfig -p |& grep -c "libreadline.so"`
if (0 == $readline_found) then
	echo "TEST-E-NOREADLINE, libreadline not found by ldconfig, so this subtest cannot test the readline path"
endif
cp $gtm_tst/$tst/inref/rl1294.m .
$gtm_tst/com/dbcreate.csh mumps
# Every step runs with HOME pointing to a directory of its own, so the history files a step finds were created
# by that step. The checks are done by readline_histcheck-ydb1294.csh, which prints PASS or WRONG.
set check = "$gtm_tst/$tst/u_inref/readline_histcheck-ydb1294.csh"

echo
echo '# Step 1 : HOME=home1 $gtm_dist/yottadb -run rl1294 < /dev/null'
echo "#          expect RUN, and no home1/.ydb_YottaDB_history"
mkdir home1
env HOME=$PWD/home1 $gtm_dist/yottadb -run rl1294 < /dev/null
$check absent home1/.ydb_YottaDB_history

echo
echo '# Step 2 : echo "write 2*21,!" | HOME=home2 $gtm_dist/yottadb -direct'
echo "#          expect 42, and no home2/.ydb_YottaDB_history"
mkdir home2
echo "write 2*21,!" | env HOME=$PWD/home2 $gtm_dist/yottadb -direct
$check absent home2/.ydb_YottaDB_history

echo
echo '# Step 3 : echo exit | HOME=home3 $gtm_dist/lke, then the same with $gtm_dist/dse and $gtm_dist/mupip'
echo "#          expect no home3/.ydb_LKE_history, home3/.ydb_DSE_history or home3/.ydb_MUPIP_history"
mkdir home3
foreach util (lke dse mupip)
	echo exit | env HOME=$PWD/home3 $gtm_dist/$util >& step3_$util.out
end
$check absent home3/.ydb_LKE_history
$check absent home3/.ydb_DSE_history
$check absent home3/.ydb_MUPIP_history

echo
echo '# Step 4 : HOME=home4 $gtm_dist/yottadb -run rl1294 < /dev/null, with home4 not writable'
echo "#          expect RUN and no READLINEFILEPERM warning"
mkdir home4
chmod 555 home4
env HOME=$PWD/home4 $gtm_dist/yottadb -run rl1294 < /dev/null >& step4.out
cat step4.out
set nperm = `grep -c READLINEFILEPERM step4.out`
if (0 == $nperm) then
	echo "PASS: no READLINEFILEPERM warning"
else
	echo "WRONG: $nperm READLINEFILEPERM warning(s), expected none"
endif
chmod 755 home4

echo
echo '# Step 5 : from a terminal, HOME=home5 $gtm_dist/yottadb -run rl1294'
echo "#          expect RUN, and no home5/.ydb_YottaDB_history since the process never enters direct mode"
mkdir home5
(env HOME=$PWD/home5 expect -d $gtm_tst/$tst/u_inref/readline_lazy_load-ydb1294.exp run > step5.exp.out) >& step5.exp.dbg
cat step5.exp.out
$check absent home5/.ydb_YottaDB_history

echo
echo '# Step 6 : from a terminal, HOME=home6 $gtm_dist/yottadb -direct, then'
echo '#          YDB>write "D","M",!'
echo "#          YDB>halt"
echo "#          expect DM, and home6/.ydb_YottaDB_history to hold the line typed at the prompt"
mkdir home6
(env HOME=$PWD/home6 expect -d $gtm_tst/$tst/u_inref/readline_lazy_load-ydb1294.exp direct > step6.exp.out) >& step6.exp.dbg
cat step6.exp.out
$check present home6/.ydb_YottaDB_history 'write "D","M",!'

echo
echo '# Step 7 : from a terminal, HOME=home7 $gtm_dist/lke, then'
echo "#          LKE>show -all"
echo "#          LKE>exit"
echo "#          expect home7/.ydb_LKE_history to hold the command typed at the prompt"
mkdir home7
(env HOME=$PWD/home7 expect -d $gtm_tst/$tst/u_inref/readline_lazy_load-ydb1294.exp lke > step7.exp.out) >& step7.exp.dbg
cat step7.exp.out
$check present home7/.ydb_LKE_history "show -all"

echo
echo '# Step 8 : from a terminal, HOME=home8 ./ydb1294_ci, a C program that calls in to ci^rl1294, which does a BREAK, then'
echo '#          YDB>write "Q","Z",!'
echo "#          YDB>zcontinue"
echo "#          expect CALLIN, QZ, BACK and ydb_ci returned 0, and no home8/.ydb_YottaDB_history"
set file = ydb1294_ci
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
echo "rl1294ci: void ci^rl1294()" > rl1294.tab
setenv ydb_ci $PWD/rl1294.tab
mkdir home8
(env HOME=$PWD/home8 expect -d $gtm_tst/$tst/u_inref/readline_lazy_load-ydb1294.exp callin > step8.exp.out) >& step8.exp.dbg
unsetenv ydb_ci
cat step8.exp.out
$check absent home8/.ydb_YottaDB_history

$gtm_tst/com/dbcheck.csh
