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

echo ""
echo "------------------------------------------------------------"
echo '# Test DO & usages with LITNONGRAPH warning does not SIG-11 and/or assert fail'
echo "------------------------------------------------------------"
set base = "ydb828do"
echo ' do &t"\t"' > $base.m
echo "# Try $base.m using [yottadb -direct]"
rm -f $base.o	# Remove any .o file to ensure compilation happens as part of "yottadb -direct"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
rm -f $base.o	# Remove any .o file to ensure compilation happens as part of "yottadb -run"
$ydb_dist/yottadb -run $base

$gtm_tst/com/dbcheck.csh
