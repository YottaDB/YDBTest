#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

echo '#####################################################################'
echo '######## Test various code issues identified by fuzz testing ########'
echo '#####################################################################'

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267088419'
echo '# Test that multiple $ZTRIGGER calls after a LVUNDEF error run fine'
echo '# Prior to YDB@4db8241a, this test failed with an assert'
echo '# Expecting only 2 LVUNDEF errors in below output in each invocation'
echo "------------------------------------------------------------"
set base = "ydb964ztriggerlvundef"
cat > $base.m << CAT_EOF
 set x=\$ztrigger("item",undef)
 set x=\$ztrigger("item",undef)
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267095573'
echo '# Test that empty -xecute string in multi-line trigger in $ZTRIGGER call issues an error'
echo '# Prior to YDB@294a0114, this test failed with a SIG-11'
echo '# Expecting only [Multi-line xecute in $ztrigger ITEM must end in newline] error in below output'
echo "------------------------------------------------------------"
set base = "ydb964ZtriggerEmptyMultiLine"
cat > $base.m << CAT_EOF
 write \$ztrigger("item","+^x -commands=S -xecute=<<")
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267101642'
echo '# Test that empty -xecute string in multi-line trigger in $ZTRIGGER call that ends in newline issues an error'
echo '# Prior to YDB@01ec2684, this test failed with a SIG-11'
echo '# Expecting only [Empty XECUTE string is invalid] error in below output'
echo "------------------------------------------------------------"
set base = "ydb964ZtriggerEmptyMultiLine2"
cat > $base.m << CAT_EOF
 write \$ztrigger("item","+^a4 -commands=S -xecute=<<"_\$c(10))
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267098363'
echo '# Test that incomplete -xecute string in $ZTRIGGER call issues an error'
echo '# Prior to YDB@a4d4a335, this test failed with a SIG-11'
echo '# Expecting only [Missing global name] error in below output'
echo "------------------------------------------------------------"
set base = "ydb964ZtriggerIncompleteXecute"
cat > $base.m << CAT_EOF
 if \$ztrigger("item","+","PAGFIbal(1) -commands=S -xecute=""")
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267141916'
echo '# Test that comma in global name list of $ZTRIGGER("SELECT") call issues an error'
echo '# Prior to YDB@e9594387, this test failed with a SIG-11'
echo '# Expecting only [Invalid global variable name in SELECT list] error in below output'
echo "------------------------------------------------------------"
set base = "ydb964ZtriggerSelectComma"
cat > $base.m << CAT_EOF
 write \$ztrigger("select",",")
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267198021'
echo '# Test that missing ")" at end of global subscript in $ZTRIGGER call issues an error'
echo '# Prior to YDB@b1b8e74b, this test failed with an ASAN heap-buffer-overflow error'
echo '# Expecting only [Missing ")" after global subscript] error in below output'
echo "------------------------------------------------------------"
set base = "ydb964ZtriggerMissingRParen"
cat > $base.m << CAT_EOF
 if \$ztrigger("item","+^a(1) -commands=S -xecute=""write 1""")
 if \$ztrigger("item","+^a(1")
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/964#note_1267160042'
echo '# Test that using naked indicator after $ZTRIGGER in ZWRITE and $NAME issues a GVNAKED error'
echo '# Prior to YDB@5a3f150a, this test failed with a SIG-11 in ZWRITE and garbage output in $NAME'
echo '# Expecting only GVNAKED error in below output'
echo "------------------------------------------------------------"
set base = "ydb964ZtriggerGVNaked"
cat > $base.m << CAT_EOF
 if \$ztrigger("item","-*")
 if \$ztrigger("item","+^x -commands=S -xecute=""w 1""")
 write ^("a")
 zwrite ^("a")
 write \$name(^("a"))
 ;
CAT_EOF
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base

echo ""
$gtm_tst/com/dbcheck.csh
