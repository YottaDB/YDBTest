#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
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
echo '# Test OPEN of a SOCKET device with a long LISTEN device parameter works fine'
echo '# This used to previously (before YDB@98837f3e) fail with a SIG-11/Assert'
echo '# Expecting ADDRTOOLONG error in below output'
echo "------------------------------------------------------------"
set base = "ydb860opensocketlisten"
cat > $base.m << CAT_EOF
 set sf=\$translate(\$justify("x",128)," ","x")
 open "s":(LISTEN=sf_":LOCAL")::"SOCKET"
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test ZGOTO using long entryref names works fine'
echo '# This used to previously (before YDB@1d843ecc) fail with a SIG-11/stack-buffer-overflow'
echo '# Expecting LABELMISSING/ZLINKFILE/FILENOTFOUND errors in below output'
echo "------------------------------------------------------------"
set base = "ydb860zgoto"
cat > $base.m << CAT_EOF
 write "# Expecting a LABELMISSING error when using a label name longer than 31 bytes",!
 set y=\$translate(\$justify("x",2**(5+\$random(16)))," ","x") zgoto "*":@y
 write "# Expecting a ZLKINKFILE/FILENOTFND error when using a routine name longer than 31 bytes",!
 set y=\$translate(\$justify("x",2**(5+\$random(16)))," ","x") zgoto "*":x+2^@y

CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
# Need to use %XCMD to set $ztrap to "incrtrap" so we continue execution of full M program inspite of errors.
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base

echo ""
echo "------------------------------------------------------------"
echo '# Test forward and reverse $QUERY in FOR loop does not SIG-11/Assert fail'
echo "------------------------------------------------------------"
@ num = 1
while ($num < 5)
	$ydb_dist/yottadb -run test$num^ydb860query
	@ num = $num + 1
end

echo ""
echo "------------------------------------------------------------"
echo '# Test ZTIMEOUT when $ETRAP has M code with a syntax error in direct mode works fine'
echo '# This used to previously (before YDB@7f378d5b) fail with a SIG-11'
echo '# Expecting LABELMISSING/ZLINKFILE/FILENOTFOUND errors in below output'
echo "------------------------------------------------------------"
foreach file ($gtm_tst/$tst/inref/ydb860ztimeoutetrap*.m)
	cp $file .
	set base = $file:t:r
	# Test direct mode
	echo "# Try $base.m using [yottadb -direct]"
	cat $base.m | $ydb_dist/yottadb -direct
	# Note : Even though the original issue was found only when running direct mode, we test "yottadb -run"
	# too just in case this encounters a regression in the future.
	echo "# Try $base.m using [yottadb -run]"
	# Need to use %XCMD to set $ztrap to "incrtrap" so we continue execution of full M program inspite of errors.
	$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base
end

echo ""
echo "------------------------------------------------------------"
echo '# Test ZLINK of a M program that has already been opened in read-write mode issues DEVICEREADONLY error'
echo '# This used to previously (before YDB@3896dddb) fail with a SIG-11'
echo '# Expecting DEVICEREADONLY error in below output'
echo "------------------------------------------------------------"
set base = "ydb860devicereadonly"
cat > $base.m << CAT_EOF
 set fn="generated.m"
 open fn:new
 use fn
 write " z"
 set \$zroutines=""
 zlink "generated.m"
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
$gtm_tst/com/dbcheck.csh
