#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

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

