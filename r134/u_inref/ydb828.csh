#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

echo '---------------------------------------------------------------------'
echo '######## Test various code issues identified by fuzz testing ########'
echo '---------------------------------------------------------------------'

echo ""
echo "------------------------------------------------------------"
echo '# Test $CHAR(0) in vector portion of $ZTIMEOUT does not SIG-11'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'S $ZTim=":"_$CHAR(0)'

echo ""
echo "------------------------------------------------------------"
echo '# Test LVUNDEF error is issued if $ZTIMEOUT is set to an undefined lvn'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'S $ZTim=xyz'

echo ""
echo "------------------------------------------------------------"
echo '# Test no memory leaks when invalid M code is specified in $ZTIMEOUT'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run ydb828ztimeout

echo ""
echo "------------------------------------------------------------"
echo '# Test $VIEW("YCOLLATE",coll,ver) does not SIG-11 if no collation library exists'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'write $VIEW("YCOLLATE",1,0),!'

echo ""
echo "------------------------------------------------------------"
echo '# Test NUMOFLOW operands in division operations do not cause %YDB-F-SIGINTDIV fatal errors'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run ydb828arith

echo ""
echo "------------------------------------------------------------"
echo '# Test retrying OPEN after INVMNEMCSPC error does not SIG-11'
echo '# Expect INVMNEMCSPC error followed by USRIOINIT error'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -direct << YDB_EOF
set dev="tmp"
open dev:(attach="")::"invalidmnemonicspace"
open dev
YDB_EOF

echo ""
echo "------------------------------------------------------------"
echo '# Test $FNUMBER with a huge 3rd parameter does not cause a SIG-11 or assert failures'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run ydb828fnumber

echo ""
echo "------------------------------------------------------------"
echo '# Test $FNUMBER with a 3rd parameter >= 1Mb issues a MAXSTRLEN error'
echo "------------------------------------------------------------"
echo "# Trying length of 2**20 : Expect MAXSTRLEN error"
$ydb_dist/yottadb -run %XCMD 'set x=$fnumber(1,"P,",2**20)'
echo "# Trying length of 2**21 : Expect MAXSTRLEN error"
$ydb_dist/yottadb -run %XCMD 'set x=$fnumber(1,"P,",2**21)'
echo "# Trying length of 2**19 : Do not expect MAXSTRLEN error"
$ydb_dist/yottadb -run %XCMD 'set x=$fnumber(1,"P,",2**19)'

echo ""
echo "------------------------------------------------------------"
echo '# Test $JUSTIFY and $FNUMBER with a huge 3rd parameter does not cause a SIG-11 or assert failures'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run ydb828justify

echo ""
echo "------------------------------------------------------------"
echo '# Test no stack buffer overflow in lower_to_upper() call in sr_unix/io_open_try.c'
echo '# Tests https://gitlab.com/YottaDB/DB/YDB/-/issues/828#note_793149685'
echo '# Expect to see a %YDB-E-INVMNEMCSPC error'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'open "x":(readonly)::"invalidmnemonicspace"'

echo ""
echo "------------------------------------------------------------"
echo '# Test no stack buffer overflow in lower_to_upper() call in sr_unix/op_fnzparse.c'
echo '# Tests https://gitlab.com/YottaDB/DB/YDB/-/issues/828#note_793151980'
echo '# Expect to see a %YDB-E-ZPARSETYPE error'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'write $zparse("test","","/usr/work/","dust.lis","abcdefghijklmnopqrstuvwxyz")'

echo ""
echo "------------------------------------------------------------"
echo '# Test no stack buffer overflow in lower_to_upper() call in sr_port/iosocket_open.c'
echo '# Tests https://gitlab.com/YottaDB/DB/YDB/-/issues/828#note_793151980'
echo '# Expect to see no errors'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -direct << YDB_EOF
open "socket":(exception="do fail^server":ioerror="trap")::"SOCKET"
close "socket"
open "socket":(exception="do fail^server":ioerror="trap")::"TOOLONGMNEMONICSPACE"
YDB_EOF

echo ""
echo "------------------------------------------------------------"
echo '# Test $INCREMENT(@glvn) with boolean expression in glvn subscript does not SIG-11'
echo '# Expect to see 2 LVUNDEF errors in the first 2 tests. And y(2)=1 in the 3rd test.'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'write $increment(@x(1&2)),!'
$ydb_dist/yottadb -run %XCMD 'write $increment(@x(y*76&$z\333733)),!'
$ydb_dist/yottadb -run %XCMD 'set x(1)="y(2)" set z=$increment(@x(1&2)) zwrite y'

echo ""
echo "------------------------------------------------------------"
echo '# Test MUMPS_INT usages in code base with HUGE numeric arguments do not SIG-11 and/or assert fail'
echo "------------------------------------------------------------"
echo '# First test with XECUTE of such expressions'
source $gtm_tst/com/is_libyottadb_asan_enabled.csh # defines "gtm_test_libyottadb_asan_enabled" env var (needed by ydb828mumpsint.m)
$ydb_dist/yottadb -run ydb828mumpsint
echo '# Next test with compile of such expressions'
sed -i 's/^#/ ;/' mumpsint.m
$ydb_dist/yottadb mumpsint >& mumpsintcompile.outx
# Filter out known errors into .out file so test framework can catch any remaining errors (not expected)
$grep -vE "%YDB-E-NUMOFLOW|%YDB-E-INVDLRCVAL" mumpsintcompile.outx > mumpsintcompile.out

echo ""
echo "------------------------------------------------------------"
echo '# Test NEW:0 or BREAK:0 followed by other commands in same M line does not SIG-11'
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -run]"
echo "------------------------------------------------------------"
@ num = 1
while ($num < 12)
	$ydb_dist/yottadb -run test$num^ydb828newbreak
	@ num = $num + 1
end
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -direct]"
echo "------------------------------------------------------------"
$grep -Ew "write|set|new|break" $gtm_tst/$tst/inref/ydb828newbreak.m > ydb828newbreakdirect.m
cat ydb828newbreakdirect.m | $ydb_dist/yottadb -direct

echo ""
echo "------------------------------------------------------------"
echo '# Test extended reference using ^[expratom1,expratom2] syntax does not cause SIG-11'
echo '# Expect %YDB-E-ZGBLDIRACC errors below but no other errors (SIG-11, assert failures etc.)'
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -run]"
echo "------------------------------------------------------------"
@ num = 1
while ($num < 7)
	$ydb_dist/yottadb -run test$num^ydb828extendedreference
	@ num = $num + 1
end
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -direct]"
echo "------------------------------------------------------------"
$grep -Ew "write|lock" $gtm_tst/$tst/inref/ydb828extendedreference.m > ydb828extendedreferencedirect.m
cat ydb828extendedreferencedirect.m | $ydb_dist/yottadb -direct

echo ""
echo "------------------------------------------------------------"
echo '# Test that compile time literal optimization on binary arithmetic operations does not cause assert failures/SIG-11'
echo '# Only expect graceful runtime errors (e.g. NUMOFLOW/DIVZERO/NEGFRACPWR) below'
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -run]"
echo "------------------------------------------------------------"
@ num = 1
while ($num < 13)
	$ydb_dist/yottadb -run test$num^ydb828arithlit
	@ num = $num + 1
end
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -direct]"
echo "------------------------------------------------------------"
$grep -Ewi "for|quit" $gtm_tst/$tst/inref/ydb828arithlit.m > ydb828arithlitdirect.m
cat ydb828arithlitdirect.m | $ydb_dist/yottadb -direct
echo "------------------------------------------------------------"
echo "# Try all test cases inside trigger xecute code : Use [mupip trigger -trigger]"
echo "# Do not expect any errors"
echo "------------------------------------------------------------"
echo "-*" > ydb828arithlit.trg
$grep 'for  ' ydb828arithlitdirect.m | sed 's/.*set x=//;' | $tst_awk '{printf "+^x -commands=SET -name=x%s -xecute=write %s\n", NR, $0}' | sed 's/xecute=/&"/;s/$/"/;' >> ydb828arithlit.trg
$ydb_dist/mupip trigger -noprompt -triggerfile=ydb828arithlit.trg
echo "------------------------------------------------------------"
echo '# Try all test cases inside trigger xecute code : Use [$ztrigger]'
echo "# Do not expect any errors"
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run %XCMD 'if $ztrigger("file","ydb828arithlit.trg")'

echo ""
echo "------------------------------------------------------------"
echo '# Test that opening same device multiple times and closing it does not cause SIG-11.'
echo '# A YottaDB build that has ASAN enabled and does not have the code fixes used to show heap-use-after-free errors.'
echo "------------------------------------------------------------"
echo '# Test multiple device op_close() in close_source_file()'
echo '# Expect ZLINKFILE/FILENOTFND/EXPR/NOTPRINCIO errors and %YDB-I-BREAK but no other errors'
set base="ydb828currdevice"
set file="$base.m"
cat > $file << CAT_EOF
a
b c
CAT_EOF
$ydb_dist/yottadb -direct << YDB_EOF
set file="$file" open file use file
set \$zroutines=""
do ^$base
set x=;
break
YDB_EOF
echo '# Test multiple device op_close() in trigger_trgfile_tpwrap_helper() -> file_input_close()'
echo '# Expect %YDB-I-BREAK but no other errors'
set file=$base.trg
cat > $file << CAT_EOF
+^x -commands=S -name=x1 -xecute="write 1"
CAT_EOF
$ydb_dist/yottadb -direct << YDB_EOF
set file="$file" open file use file
if \$ztrigger("file",file)
break
YDB_EOF
echo '# Test multiple device op_close() in jobexam_dump()'
echo '# Expect %YDB-I-BREAK but no other errors'
set file=$base.txt
$ydb_dist/yottadb -direct << YDB_EOF
set file=\$zparse("$file")
open file use file
set x=\$zjobexam(file)
zwrite x
break
YDB_EOF
echo '# Test multiple device op_close() in close_list_file()'
echo '# Expect %YDB-I-BREAK but no other errors'
set file=$base.lis
echo " b" > ${base}.m
$ydb_dist/yottadb -direct << YDB_EOF
set file=\$zparse("$file")
open file use file
set \$zcompile="-machine -lis="_file
zcompile "${base}.m"
break
YDB_EOF
# Remove all ^x triggers loaded till now as it would otherwise disturb later sections of the test that use ^x
$ydb_dist/yottadb -run %XCMD 'if $ztrigger("item","-*")'

echo ""
echo "------------------------------------------------------------"
echo '# Test DO & usages with LITNONGRAPH warning does not SIG-11 and/or assert fail'
echo "------------------------------------------------------------"
set base = "ydb828do"
echo ' do &t"\t"' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that PATNOTFOUND error inside FOR does not SIG-11 and/or assert fail'
echo "------------------------------------------------------------"
set base = "ydb828forpatnotfound"
echo ' FOR J=0:.0005:.0?1SS",\n QUIT\n' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that OPEN /dev/full does not SIG-11'
echo "------------------------------------------------------------"
set base = "ydb828open"
echo ' open "/dev/full"' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that ZSHOW "D" on PIPE device does not SIG-11 if device parameters are specified multiple times'
echo "------------------------------------------------------------"
set base = "ydb828zshowd"
cp $gtm_tst/$tst/inref/$base.m .
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that NEW @ inside FOR with a control variable does not SIG-11'
echo '# Expecting only a LVUNDEF error instead'
echo "------------------------------------------------------------"
set base = "ydb828fornewat"
echo ' for i=1:1 new @"(x)"' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test GTM-9371 : OC_FORCENUM in boolean expressions does not cause SIG-11/GTMASSERT2 (used to before YDB@ba22f762)'
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -run]"
echo "------------------------------------------------------------"
@ num = 1
while ($num < 6)
	$ydb_dist/yottadb -run test$num^ydb828forcenumlit
	@ num = $num + 1
end
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -direct]"
echo "------------------------------------------------------------"
$grep -Ewi "write|for" $gtm_tst/$tst/inref/ydb828forcenumlit.m > ydb828forcenumlitdirect.m
cat ydb828forcenumlitdirect.m | $ydb_dist/yottadb -direct

echo ""
echo "------------------------------------------------------------"
echo '# Test that $query(@"a,") does not GTMASSERT2'
echo '# Expecting only a INDEXTRACHARS error instead'
echo "------------------------------------------------------------"
set base = "ydb828dlrqueryindirect"
echo ' write $query(@"a,")' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that parse error in device parameter specification does not GTMASSERT2'
echo '# Trying out [use $principal:("] : Expecting a DEVPARPARSE error (not a GTMASSERT2 error)'
echo "------------------------------------------------------------"
set base = "ydb828devparparse1"
echo ' use $principal:("' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that parse error in device parameter specification does not assert fail in linetail.c in Debug builds'
echo '# Trying out [use $principal:("] : Expecting a DEVPARPARSE error'
echo '# This used to previously (before YDB@d8e6fc32) fail as'
echo '#     %YDB-F-ASSERT, Assert failed in sr_port/linetail.c line 40 for expression (TREF(source_error_found))'
echo "------------------------------------------------------------"
set base = "ydb828devparparse2"
echo ' open f:(commO"ecuse f' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test that > 31 subscripts in ZWRITE does not cause SIG-11 OR heap-buffer-overflow error (with ASAN)'
echo '# Test instead that it issues MAXNRSUBSCRIPTS error'
echo '# Invoking [yottadb -run ydb828zwritemaxnrsubs]'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run ydb828zwritemaxnrsubs

echo ""
echo "------------------------------------------------------------"
echo '# Test SETZDIRTOOLONG error is issued by SET $ZDIR when string is 4096 bytes long'
echo '# This used to previously (before YDB@22aaad3d) fail with a stack-buffer-overflow ASAN error'
echo '# Trying out [set $zdir=$justify(1," ",4096)] : Expecting a SETZDIRTOOLONG error'
echo "------------------------------------------------------------"
set base = "ydb828setzdirtoolong"
echo ' set $zdir=$justify(1," ",4096)' > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
set str = 'write:+"1E47" "Should not see this string",!'
echo "------------------------------------------------------------"
echo '# Test NUMOFLOW error is issued by WRITE:+"1E47"'
echo '# This used to previously (before YDB@108e062c) fail with a SIG-11'
echo '# Trying out ['$str'] : Expecting a SETZDIRTOOLONG error'
echo "------------------------------------------------------------"
set base = "ydb828numoflow"
echo ' '$str > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
set str = 'set ^[$order(@x,1)'
echo "------------------------------------------------------------"
echo '# Test EXTGBLDEL error is issued by SET ^[$ORDER(@x,1)'
echo '# This used to previously (before YDB@108e062c1) fail with a %YDB-F-GTMASSERT2 error'
echo '# Trying out ['$str'] : Expecting a EXTGBLDEL error'
echo "------------------------------------------------------------"
set base = "ydb828extgbldel"
echo ' '$str > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test ZWRITE works fine after LVUNDEF error in FOR command'
echo '# This used to previously (before YDB@59a129ce) fail with a SIG-11/ASSERT'
echo "------------------------------------------------------------"
set base = "ydb828forlvundef"
cat > $base.m << CAT_EOF
 set x("a")=1
 for x(1)=x("b")
 zwrite
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
set str = 'U -I:R)"'
echo "------------------------------------------------------------"
echo '# Test DEVPARPARSE error is issued even if it is followed by another parse error'
echo '# This used to previously (before YDB@7c455a99) fail with a %YDB-F-GTMASSERT2 error'
echo '# Trying out ['$str'] : Expecting a DEVPARPARSE error'
echo "------------------------------------------------------------"
set base = "ydb828devparparse3"
echo ' '$str > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
set str = 'view "noundef" set res=$zahandle(x(1)) zwrite res'
echo "------------------------------------------------------------"
echo '# Test $ZAHANDLE of undefined lvn when VIEW NOUNDEF is enabled does not SIG-11'
echo '# This used to previously (before YDB@c79a3dee) fail with a SIG-11'
echo '# Trying out ['$str'] : Expecting empty string as the value of "res"'
echo "------------------------------------------------------------"
set base = "ydb828zahandlenoundef"
echo ' '$str > $base.m
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
$gtm_tst/com/dbcheck.csh
