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
echo '# [YDB#1340] $ZTRIGGER() and MUPIP TRIGGER issue "Too many subscripts" for a trigger with more than  #'
echo '# 31 local variable names in its subscripts, and a subscript can still have more than one name       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A trigger subscript can have a local variable name, and more than one, for example ^x(a=b=1:2).'
echo '# The trigger definition parser saved each name in stack arrays of 32 entries without checking the'
echo '# count, so more names than that overwrote the process stack. Before the fix, 32 names loaded, and'
echo '# 200 names in one subscript terminated the process with a SIG-11 in YottaDB r2.06, both with'
echo '# $ZTRIGGER() and MUPIP TRIGGER. And when a trigger with more names than subscripts was used, a Debug'
echo '# build failed an assert in gv_trigger.c (numlvsubs <= numsubs).'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1340.m .
# A key size of 255 so that stage 3 can SET a node with 31 subscripts
$gtm_tst/com/dbcreate.csh mumps 1 255 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : +^x(a=b=1:2,c=d=:) with -xecute="set ^y=$name(z(a,b,c,d))", then SET ^x(1,"z")=1'
echo '# Before the fix : the same in a Release build, but an assert in gv_trigger.c in a Debug build'
echo '# With the fix   : expect the trigger to load, and a and b to be 1, and c and d to be "z" in the'
echo '#                  trigger code'
echo '# Command : $gtm_dist/mumps -run chain^ydb1340'
$gtm_dist/mumps -run chain^ydb1340
echo

echo '# Stage 2 : 31 chained names in one subscript, +^w31(v1=v2=...=v31=1), then SET ^w31(1)=1'
echo '# Before the fix : the same in a Release build, but an assert in gv_trigger.c in a Debug build'
echo '# With the fix   : expect the trigger to load, and v1 and v31 to be 1 in the trigger code'
echo '# Command : $gtm_dist/mumps -run one31^ydb1340'
$gtm_dist/mumps -run one31^ydb1340
echo

echo '# Stage 3 : 31 subscripts with one name each, +^v(v1=*,v2=*,...,v31=*), then SET ^v(1,2,...,31)=1'
echo '# Before the fix : the same (this stage is a control)'
echo '# With the fix   : expect the trigger to load, and v1 to be 1 and v31 to be 31 in the trigger code'
echo '# Command : $gtm_dist/mumps -run sub31^ydb1340'
$gtm_dist/mumps -run sub31^ydb1340
echo

echo '# Stage 4 : 32 chained names in one subscript, +^w32(v1=v2=...=v32=1)'
echo '# Before the fix : the trigger loaded'
echo '# With the fix   : expect "Too many subscripts" and $ZTRIGGER() to return 0'
echo '# Command : $gtm_dist/mumps -run one32^ydb1340'
$gtm_dist/mumps -run one32^ydb1340
echo

echo '# Stage 5 : 200 chained names in one subscript, +^w200(v1=v2=...=v200=1)'
echo '# Before the fix : a SIG-11 (KILLBYSIGSINFO1)'
echo '# With the fix   : expect "Too many subscripts" and $ZTRIGGER() to return 0'
echo '# Command : $gtm_dist/mumps -run one200^ydb1340 >& one200.out'
$gtm_dist/mumps -run one200^ydb1340 >& one200.out
# The error message repeats the trigger definition, which is about 1000 bytes long, so check for the message
# instead of showing the output
if ((1 == `grep -c "^Too many subscripts" one200.out`) && (1 == `grep -c "^PASS : " one200.out`) \
		&& (3 == `grep -vc '^$' one200.out`)) then
	echo "PASS : one200.out has the error, the trigger definition, the return value check and nothing else"
else
	echo "FAIL : one200.out follows"
	cat one200.out
endif
echo

echo '# Stage 6 : MUPIP TRIGGER with a trigger file that has 200 chained names in one subscript'
echo '# Before the fix : a SIG-11 (KILLBYSIGSINFO1)'
echo '# With the fix   : expect "Too many subscripts", and the trigger file entry to have an error'
echo '# Command : $gtm_dist/mumps -run trgfile^ydb1340, then'
echo '#           $gtm_dist/mupip trigger -triggerfile=trig200.trg -noprompt'
$gtm_dist/mumps -run trgfile^ydb1340
$gtm_dist/mupip trigger -triggerfile=trig200.trg -noprompt >& mupip200.out
set stat = $status
if ((1 == `grep -c "^File trig200.trg, Line 1: Too many subscripts" mupip200.out`) \
		&& (1 == `grep -c "^1 trigger file entries have errors" mupip200.out`) && (0 != $stat)) then
	echo "PASS : MUPIP TRIGGER reported the error for the entry, and its exit status is not 0"
else
	echo "FAIL : MUPIP TRIGGER exit status is $stat. mupip200.out follows"
	cat mupip200.out
endif
echo '# With the fix, expect MUNOACTION, as no trigger file entry was applied'
$gtm_tst/com/check_error_exist.csh mupip200.out MUNOACTION
echo

echo '# Stage 7 : $ZTRIGGER("SELECT")'
echo '# Before the fix : also showed the ^w32 trigger of stage 4'
echo '# With the fix   : expect the 3 triggers loaded by stages 1 to 3 and no other'
echo '# Command : $gtm_dist/mumps -run %XCMD '"'"'if $ztrigger("select")'"'"
$gtm_dist/mumps -run %XCMD 'if $ztrigger("select")'
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
