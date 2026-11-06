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
echo '# [YDB#1343] INVDLRCVAL for a literal $CHAR() argument reports the invalid value at run time         #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# In UTF-8 mode, the compiler evaluates a $CHAR() whose arguments are all literals. For an argument that'
echo '# is not a valid code point it issues INVDLRCVAL as a warning. It also inserted code to issue INVDLRCVAL'
echo '# at run time, without the value, so the error reported the value as 0, and it returned an empty string'
echo '# literal whose character length was wrong, which $TRANSLATE() could use as its default search string.'
echo '# The compiler now generates a run time call of $CHAR() for such a $CHAR(), which issues INVDLRCVAL with'
echo '# the value if and when it runs.'
echo

cp $gtm_tst/$tst/inref/ydb1343.m $gtm_tst/$tst/inref/ydb1343bad.m .
$switch_chset "UTF-8" >& switch_chset_utf8.out

echo '# Stage 1 : Direct Mode, write $char(10000000)'
echo 'write $char(10000000)' > stage1.inp
echo '# Command : $gtm_dist/mumps -direct < stage1.inp >& stage1.out'
echo '# Before the fix : INVDLRCVAL with the value 0, so check_error_exist.csh reported TEST-E-ERRORNOTSEEN'
echo '# With the fix   : expect INVDLRCVAL with the value 10000000'
$gtm_dist/mumps -direct < stage1.inp >& stage1.out
$gtm_tst/com/check_error_exist.csh stage1.out 'INVDLRCVAL, Invalid .CHAR.. value 10000000$'
echo

echo '# Stage 2 : XECUTE "write $char(1114112)" from a routine'
echo '# Command : $gtm_dist/mumps -run xecute^ydb1343'
echo '# Before the fix : INVDLRCVAL with the value 0, so the line below was a FAIL line'
echo '# With the fix   : expect INVDLRCVAL with the value 1114112'
$gtm_dist/mumps -run xecute^ydb1343
echo

echo '# Stage 3 : compile a routine with the line "set x=$char(65,1114112)", then run that line'
echo '# Command : $gtm_dist/mumps ydb1343bad.m'
echo '# Before the fix : the same warning, but running the line issued INVDLRCVAL with the value 0, so the'
echo '#                  last line below was a FAIL line'
echo '# With the fix   : expect the compiler to issue the INVDLRCVAL warning with the value 1114112, and'
echo '#                  running the line to issue INVDLRCVAL with the value 1114112'
$gtm_dist/mumps ydb1343bad.m
echo '# Command : $gtm_dist/mumps -run rtn^ydb1343'
$gtm_dist/mumps -run rtn^ydb1343
echo

echo '# Stage 4 : Direct Mode, write $translate($char(0,10000000,""))'
echo 'write $translate($char(0,10000000,""))' > stage4.inp
echo '# Command : $gtm_dist/mumps -direct < stage4.inp >& stage4.out'
echo '# Before the fix : an assert failure in create_utf8_xlate_table.c in a Debug build, and INVDLRCVAL with'
echo '#                  the value 0 in a Release build, so check_error_exist.csh reported TEST-E-ERRORNOTSEEN'
echo '# With the fix   : expect INVDLRCVAL with the value 10000000'
$gtm_dist/mumps -direct < stage4.inp >& stage4.out
$gtm_tst/com/check_error_exist.csh stage4.out 'INVDLRCVAL, Invalid .CHAR.. value 10000000$'
echo

echo '# Stage 5 : Direct Mode, set x=$select(1:"ok",1:$char(1114112))'
echo 'set x=$select(1:"ok",1:$char(1114112)) write $select("ok"=x:"PASS : $SELECT() returned ok",1:"FAIL : $SELECT() returned "_x),!' > stage5.inp
echo '# Command : $gtm_dist/mumps -direct < stage5.inp'
echo '# Before the fix : the same result as below'
echo '# With the fix   : expect "ok" and no error, as $SELECT() does not evaluate the $CHAR() after a true'
echo '#                  condition (YDB#371)'
$gtm_dist/mumps -direct < stage5.inp
echo

echo '# Stage 6 : Direct Mode, view "NOBADCHAR" set x=$length($char(65,1114112,66)) on one line'
echo 'view "NOBADCHAR" set x=$length($char(65,1114112,66)) write $select(2=x:"PASS : $length() returned 2",1:"FAIL : $length() returned "_x),! view "BADCHAR"' > stage6.inp
echo '# Command : $gtm_dist/mumps -direct < stage6.inp'
echo '# Before the fix : INVDLRCVAL with the value 0, as the compiler checked the code point before VIEW'
echo '#                  "NOBADCHAR" ran, so the line below was not a PASS line'
echo '# With the fix   : expect 2, as $CHAR() now runs after VIEW "NOBADCHAR" and drops the invalid code'
echo '#                  point, as it does for an argument that is not a literal'
$gtm_dist/mumps -direct < stage6.inp
echo

echo '# Stage 7 : Direct Mode, set x=$char(65,66,1046), all valid code points'
echo 'set x=$char(65,66,1046) write $select((3=$length(x))&(4=$zlength(x)):"PASS : 3 characters in 4 bytes",1:"FAIL : "_$length(x)_" characters in "_$zlength(x)_" bytes"),!' > stage7.inp
echo '# Command : $gtm_dist/mumps -direct < stage7.inp'
echo '# Before the fix : the same result as below'
echo '# With the fix   : expect 3 characters in 4 bytes'
$gtm_dist/mumps -direct < stage7.inp
echo

echo '# Stage 8 : Direct Mode, load a trigger whose code has an invalid literal $CHAR() argument, then a SET'
echo '# Command : $gtm_tst/com/dbcreate.csh mumps (the trigger needs a database)'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo 'set r=$ztrigger("item","+^x -commands=S -xecute=""set y=$char(65,1114112) set ^z=1""") write "$ztrigger() returned ",r,!' > stage8.inp
echo 'set ^x=1 write $select(0=$data(^z):"PASS : the trigger was not loaded",1:"FAIL : the trigger ran"),!' >> stage8.inp
echo '# Command : $gtm_dist/mumps -direct < stage8.inp >& stage8.out'
echo '# Before the fix : a Debug build failed an assert in gvname2naked_optimize.c after the INVDLRCVAL error. A'
echo '#                  Release build gave the result below'
echo '# With the fix   : expect INVDLRCVAL with the value 1114112, and $ZTRIGGER() returning 0 as the trigger'
echo '#                  is not loaded (in a trigger, INVDLRCVAL is an error, not a warning)'
$gtm_dist/mumps -direct < stage8.inp >& stage8.out
if (`$grep -c -- "-F-" stage8.out`) then
	echo "FAIL : stage8.out has a fatal error"
else
	echo "PASS : no fatal error in stage8.out"
endif
$grep -E '^(PASS|FAIL|.ztrigger\(\) returned)' stage8.out
$gtm_tst/com/check_error_exist.csh stage8.out 'INVDLRCVAL, Invalid .CHAR.. value 1114112$'
$gtm_tst/com/dbcheck.csh >& dbcheck.out
echo
echo "# Done"
