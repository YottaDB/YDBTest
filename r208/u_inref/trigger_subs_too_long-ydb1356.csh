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
echo '# [YDB#1356] $ZTRIGGER() and MUPIP TRIGGER reject a trigger whose subscript is a string too long to  #'
echo "# fit in a key                                                                                       #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# $ZTRIGGER() and MUPIP TRIGGER did not check the length of a string subscript in a trigger'
echo '# specification. The first update of the global loads the trigger, and gvtr_process_range() converts'
echo '# each subscript to the key form with mval2subsc(), which issued GVSUBOFLOW for a subscript too long'
echo '# to fit in a key. So every SET of the global failed with GVSUBOFLOW until the trigger was deleted. A'
echo '# Debug build failed an assert in stp_gcol_src.h instead. With the fix, $ZTRIGGER() and MUPIP TRIGGER'
echo '# reject such a trigger with "Subscript too long to fit in a key".'
echo '#'
echo '# The region has the largest possible key size (1019 bytes). A key whose only subscript is a string of'
echo '# n bytes has n + 5 bytes with a one character global name (and one more byte for each byte that is'
echo '# 0x00 or 0x01), so the longest string that fits in a key as the only subscript is 1014 bytes.'
echo '#'
echo '# Each stage runs in a new process. Without the fix, stages 1, 2, 4, 5, 7, 8, 10, 11, 13, 15, 16 and 18'
echo '# print FAIL (in a Debug build, the SET of ^a(1) in stages 1, 4 and 16, of ^b(1) in stage 8, of ^c(1) in'
echo '# stage 11 and of ^d(1) in stage 13 fails an assert in stp_gcol_src.h), and stages 3, 6, 9, 12, 14 and 17'
echo '# PASS.'
echo

cp $gtm_tst/$tst/inref/ydb1356.m .
$gtm_tst/com/dbcreate.csh mumps 1 -key_size=1019 -record_size=4080 -block_size=4096 >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output follows."
	cat dbcreate.out
	exit 1
endif

foreach stage (1 2 3 4 5 6)
	switch ($stage)
	case 1:
		echo '# Stage 1 : $ZTRIGGER("ITEM") of [+^a("xxx...") -commands=S -xecute="set ^cnt=^cnt+1"] with 1030 x'"'"'s'
		echo '# Before the fix : $ZTRIGGER returned 1, and SET ^a(1) issued GVSUBOFLOW'
		echo '# With the fix   : expect $ZTRIGGER to return 0 with "Subscript too long to fit in a key", and SET'
		echo '#                  ^a(1) to work'
		breaksw
	case 2:
		echo '# Stage 2 : the same with 1015 x'"'"'s (the shortest string subscript that does not fit in a key)'
		echo '# Before the fix : $ZTRIGGER returned 1 (for a trigger that can never be invoked), and SET ^a(1)'
		echo '#                  worked, as the subscript fits in the buffer that gvtr_process_range() uses'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^a(1) to work'
		breaksw
	case 3:
		echo '# Stage 3 : the same with 1014 x'"'"'s (the longest string subscript that fits in a key)'
		echo '# Before the fix : $ZTRIGGER returned 1, SET ^a(1) worked, and the SET of ^a("xxx...") invoked the'
		echo '#                  trigger (this stage is a control)'
		echo '# With the fix   : expect $ZTRIGGER to return 1, SET ^a(1) to work, and a SET of ^a("xxx...") to'
		echo '#                  invoke the trigger'
		breaksw
	case 4:
		echo '# Stage 4 : the same with the range "a":"xxx..." with 1030 x'"'"'s'
		echo '# Before the fix : $ZTRIGGER returned 1, and SET ^a(1) issued GVSUBOFLOW'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^a(1) to work'
		breaksw
	case 5:
		echo '# Stage 5 : the same with $CHAR(1,1,...,1) with 508 1'"'"'s (1016 bytes in the key)'
		echo '# Before the fix : $ZTRIGGER returned 1 (for a trigger that can never be invoked), and SET ^a(1)'
		echo '#                  worked, as the subscript fits in the buffer that gvtr_process_range() uses'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^a(1) to work'
		breaksw
	case 6:
		echo '# Stage 6 : the same with $CHAR(1,1,...,1) with 507 1'"'"'s (1014 bytes in the key)'
		echo '# Before the fix : $ZTRIGGER returned 1, SET ^a(1) worked, and the SET of ^a($CHAR(1,1,...)) invoked'
		echo '#                  the trigger (this stage is a control)'
		echo '# With the fix   : expect $ZTRIGGER to return 1, SET ^a(1) to work, and a SET of ^a($CHAR(1,1,...))'
		echo '#                  to invoke the trigger'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run stage^ydb1356 '"$stage"
	$gtm_dist/mumps -run stage^ydb1356 $stage
	echo
end

echo '# Stage 7 : MUPIP TRIGGER -TRIGGERFILE of a file with [+^b("xxx...") -commands=S -xecute="set y=1"]'
echo '#           with 1030 x'"'"'s'
echo '# Before the fix : MUPIP TRIGGER added the trigger'
echo '# With the fix   : expect "Subscript too long to fit in a key" and MUNOACTION'
$gtm_dist/mumps -run %XCMD 'write "+^b(""",$translate($justify("",1030)," ","x"),""") -commands=S -xecute=""set y=1""",!' >& big.trg
echo '# Command : $gtm_dist/mupip trigger -triggerfile=big.trg'
$gtm_dist/mupip trigger -triggerfile=big.trg >& mupip_trigger.out
$grep -q "Subscript too long to fit in a key" mupip_trigger.out
if ($status) then
	echo 'FAIL : MUPIP TRIGGER did not issue "Subscript too long to fit in a key". Output follows.'
	cat mupip_trigger.out
else
	echo 'PASS : MUPIP TRIGGER issued "Subscript too long to fit in a key"'
endif
$gtm_tst/com/check_error_exist.csh mupip_trigger.out MUNOACTION
echo

echo '# Stage 8 : SET ^b(1)'
echo '# Before the fix : GVSUBOFLOW'
echo '# With the fix   : expect the SET to work'
echo '# Command : $gtm_dist/mumps -run stage^ydb1356 8'
$gtm_dist/mumps -run stage^ydb1356 8
echo

echo '# Stages 9 to 15 use a test collation (r208/inref/col_double.c) as collation 1, in which each byte of'
echo '# a string is stored twice. With it, a key with a string subscript of n bytes has 2n + 5 bytes, so the'
echo '# longest string subscript that fits in a key is 507 bytes. The trigger load converts each subscript'
echo '# with the collation of the global, and $ZTRIGGER() and MUPIP TRIGGER now check the subscripts with that'
echo '# collation too.'
source $gtm_tst/com/cre_coll_sl.csh $tst/inref/col_double.c 1 >& cre_coll_sl.out
unsetenv gtm_local_collate	# Unset value set by com/cre_coll_sl.csh
echo

foreach stage (9 10 11)
	switch ($stage)
	case 9:
		echo '# Stage 9 : $ZTRIGGER("ITEM") of [+^c("xxx...") -commands=S -xecute="set ^cnt=^cnt+1"] with 507 x'"'"'s,'
		echo '#           where ^c has collation 1 (the longest string subscript that fits in a key)'
		echo '# Before the fix : $ZTRIGGER returned 1, SET ^c(1) worked, and the SET of ^c("xxx...") invoked the'
		echo '#                  trigger (this stage is a control)'
		echo '# With the fix   : expect the same'
		breaksw
	case 10:
		echo '# Stage 10 : the same with 508 x'"'"'s (the shortest string subscript that does not fit in a key)'
		echo '# Before the fix : $ZTRIGGER returned 1 (for a trigger that can never be invoked), and SET ^c(1)'
		echo '#                  worked'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^c(1) to work'
		breaksw
	case 11:
		echo '# Stage 11 : the same with 600 x'"'"'s (whose key form does not fit in the buffer of the collation)'
		echo '# Before the fix : $ZTRIGGER returned 1, and SET ^c(1) failed with the error of the collation routine'
		echo '#                  (an assert in stp_gcol_src.h in a Debug build)'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^c(1) to work'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run stage^ydb1356 '"$stage"
	$gtm_dist/mumps -run stage^ydb1356 $stage
	echo
end

echo '# Stage 12 : $ZTRIGGER("ITEM") of [+^d("xxx...") -commands=S -xecute="set ^cnt=^cnt+1"] with 600 x'"'"'s,'
echo '#            and of the same with ^e("xxx...":"z") (a range whose left end has 600 x'"'"'s) and'
echo '#            ^f("a":"xxx...") (a range whose right end has 600 x'"'"'s), while each global has the'
echo '#            standard collation, then give each global collation 1 with ^%GBLDEF'
echo '# Before the fix : $ZTRIGGER returned 1 for each trigger'
echo '# With the fix   : expect the same, as each subscript fits in a key with the standard collation'
echo '# Command : $gtm_dist/mumps -run stage^ydb1356 12'
$gtm_dist/mumps -run stage^ydb1356 12
echo

echo '# Stage 13 : in a new process, SET ^d(1), ^e(1) and ^f(1), each of which loads the trigger of stage 12'
echo '#            on that global with collation 1, then delete the triggers and SET each node again'
echo '# Before the fix : each first SET failed with the error of the collation routine (an assert in'
echo '#                  stp_gcol_src.h at SET ^d(1) in a Debug build)'
echo '# With the fix   : expect each first SET to issue TRIGSUBS2BIG and store nothing, and each SET after'
echo '#                  the triggers are deleted to work'
echo '# Command : $gtm_dist/mumps -run stage^ydb1356 13'
$gtm_dist/mumps -run stage^ydb1356 13 >& stage13.out
$grep -E "^(PASS|FAIL) " stage13.out
echo

foreach stage (14 15 16 17 18)
	switch ($stage)
	case 14:
		echo '# Stage 14 : $ZTRIGGER("ITEM") of a trigger on ^c with two subscripts, ?1(1"a,",1"b") and'
		echo '#            x="a""b":"xxx...";"c";:"d" with 507 x'"'"'s (a pattern with parentheses, a local'
		echo '#            variable name, a string with a double-quote, ranges, one with an open side, and'
		echo '#            alternations)'
		echo '# Before the fix : $ZTRIGGER returned 1, SET ^c(1) worked, and the SET of ^c("b","c") invoked the'
		echo '#                  trigger (this stage is a control)'
		echo '# With the fix   : expect the same'
		breaksw
	case 15:
		echo '# Stage 15 : the same with 508 x'"'"'s at the end of the range'
		echo '# Before the fix : $ZTRIGGER returned 1, and SET ^c(1) worked'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^c(1) to work'
		breaksw
	case 16:
		echo '# Stage 16 : $ZTRIGGER("ITEM") of [+^a("xxx...":"z") -commands=S -xecute="set ^cnt=^cnt+1"] with'
		echo '#            1030 x'"'"'s (a range whose left end does not fit in a key), where ^a has the standard'
		echo '#            collation'
		echo '# Before the fix : $ZTRIGGER returned 1, and SET ^a(1) issued GVSUBOFLOW (an assert in stp_gcol_src.h'
		echo '#                  in a Debug build)'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^a(1) to work'
		breaksw
	case 17:
		echo '# Stage 17 : $ZTRIGGER("ITEM") of a trigger on ^abcdefghijklmnopqrstuvwxyzabcde("xxx...") with 984'
		echo '#            x'"'"'s (the longest string subscript that fits in a key of a global with a name of 31'
		echo '#            characters)'
		echo '# Before the fix : $ZTRIGGER returned 1, SET ^abcdefghijklmnopqrstuvwxyzabcde(1) worked, and the SET of'
		echo '#                  ^abcdefghijklmnopqrstuvwxyzabcde("xxx...") invoked the trigger (this stage is a'
		echo '#                  control)'
		echo '# With the fix   : expect the same'
		breaksw
	case 18:
		echo '# Stage 18 : the same with 985 x'"'"'s (the shortest string subscript that does not fit in a key of'
		echo '#            that global, but fits in a key of a global with a shorter name)'
		echo '# Before the fix : $ZTRIGGER returned 1 (for a trigger that can never be invoked), and SET'
		echo '#                  ^abcdefghijklmnopqrstuvwxyzabcde(1) worked'
		echo '# With the fix   : expect $ZTRIGGER to return 0, and SET ^abcdefghijklmnopqrstuvwxyzabcde(1) to work'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run stage^ydb1356 '"$stage"
	$gtm_dist/mumps -run stage^ydb1356 $stage
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
