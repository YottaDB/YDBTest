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
echo '# [YDB#1316] $ZTRIGGER("ITEM") gets no SIG-11 or false errors after a stringpool garbage collection, #'
echo '# and leaves its argument unchanged                                                                  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# When the trigger definition passed to $ZTRIGGER("ITEM") contains a newline, trigger_update_rec()'
echo '# kept C pointers into it. The definition is usually in the stringpool, and calls made while those'
echo '# pointers were in use can run a garbage collection, which moves the definition but not the C'
echo '# pointers. Stages 1 to 3 and 5 call $ZTRIGGER("ITEM") 20000 or more times with a definition built by'
echo '# concatenation, so that it is in the stringpool, and allocate a string of random length before each'
echo '# call, so that garbage collections happen at varying points. Each stage checks that every call'
echo '# returns 1 and leaves its argument unchanged.'
echo '#'
echo '# Before the fix, stages 1 to 3 and 5 failed, at least on some runs, since it depends on where the'
echo '# garbage collections happen. Stage 4 passes without the fix too; it checks that a definition more'
echo '# than twice as long as an earlier one still works now that the definition is copied into a malloced'
echo '# buffer that then has to be replaced by a bigger one. Stage 5 has a qualifier after the closing >> of'
echo '# a multi-line -xecute, which only YottaDB accepts, so it runs only with a YottaDB build. The other'
echo '# stages also run with GT.M.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1316.m .

# With journaling, each of the about 90000 $ZTRIGGER calls syncs the journal file to disk, which takes many minutes
# on a slow disk, for example 18 minutes or more in the pipeline, against about 1 minute there without journaling.
# Journaling has nothing to do with what this subtest verifies, so disable test-system dictated journaling.
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : multi-line -xecute and a numeric subscript (the case reported in YDB#1316)'
echo '#   +^OR(sub1=100,sub2=0:$C(0)) -command=kill -name=multi -xecute=<<<newline> do dft($reference) quit<newline>...'
echo '# Command : $gtm_dist/mumps -run multi^ydb1316'
echo '#   expect all 20000 calls to return 1 and none to change its argument'
echo '# Before the fix, a Release build terminated with KILLBYSIGSINFO1, or issued compilation errors such as'
echo '# MULTLAB for an XECUTE string read from freed memory, and a Debug build failed an assert in'
echo '# trigger_update.c, so the lines below were missing'
$gtm_dist/mumps -run multi^ydb1316
echo

echo '# Stage 2 : single-line definition that ends in a newline, with a numeric subscript'
echo '#   +^X(sub=1) -command=S -name=single -xecute="set y=1"<newline>'
echo '# Command : $gtm_dist/mumps -run single^ydb1316'
echo '#   expect all 20000 calls to return 1 and none to change its argument'
echo '# Before the fix, a Release build had a few of the calls return 0 with "Error : Newline allowed only'
echo '# inside multi-line xecute in $ztrigger ITEM", so the first line below was a WRONG line, and a Debug'
echo '# build failed an assert in trigger_update.c'
$gtm_dist/mumps -run single^ydb1316
echo

echo '# Stage 3 : multi-line -xecute, a new trigger per call, while the stringpool keeps expanding'
echo '#   +^D -command=kill -name=t<i> -xecute=<<<newline> set ^B=<i><newline> set ^C=<i><newline>'
echo '# Command : $gtm_dist/mumps -run newtrig^ydb1316'
echo '#   expect all 30000 calls to return 1 and none to change its argument, and $ZTRIGGER("SELECT") to show'
echo '#   all 30000 triggers, each with the XECUTE string of its own call'
echo '# Before the fix, most runs of a Release build, and some runs of a Debug build, terminated with'
echo '# KILLBYSIGSINFO1 before all 30000 calls were done, so the lines below were missing'
$gtm_dist/mumps -run newtrig^ydb1316
echo

echo '# Stage 4 : multi-line -xecute, each definition more than twice as long as the one before'
echo '#   +^E(sub=<i>) -command=kill -name=big<i> -xecute=<<<newline> set ^F(<i>)=$length("<spaces>")<newline>'
echo '# Command : $gtm_dist/mumps -run bigger^ydb1316'
echo '#   expect all 4 calls to return 1 and none to change its argument, and each trigger, when it runs, to'
echo '#   store the length of its own XECUTE string'
echo '# Before the fix, the same results, since the buffer that has to be replaced by a bigger one is new'
$gtm_dist/mumps -run bigger^ydb1316
echo

if ($gtm_exe:h:t =~ V*_R*) then
	# Only YottaDB accepts a qualifier after the closing >> of a multi-line -xecute
	echo '# Stage 5 : multi-line -xecute followed by a qualifier after the closing >> (YottaDB only)'
	echo '#   +^A -command=kill -xecute=<<<newline> set ^B=1<newline>>><newline>-name=reorder'
	echo '# Command : $gtm_dist/mumps -run reorder^ydb1316'
	echo '#   expect all 20000 calls to return 1 and none to change its argument'
	echo '# Before the fix, every call changed its argument to the definition with -name=reorder moved ahead of'
	echo '# -xecute, so the second line below was a WRONG line for all 20000 calls, and a Debug build also'
	echo '# terminated with KILLBYSIGSINFO1 when a garbage collection moved the definition'
	$gtm_dist/mumps -run reorder^ydb1316
	echo
endif

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
