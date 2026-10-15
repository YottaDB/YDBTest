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
echo '# [YDB#1305] $QLENGTH, $QSUBSCRIPT and 2-argument $NAME accept a name with a $ZYSQLNULL subscript   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# $NAME writes a $ZYSQLNULL subscript as $ZYSQLNULL. The parser that $QLENGTH, $QSUBSCRIPT and'
echo '# 2-argument $NAME of an indirect reference use took a subscript starting with $ to be $C() or $ZCH(),'
echo '# so they issued NOCANONICNAME for such a name, and 2-argument $NAME failed an assert in Debug builds.'
echo '#'
echo '# Stages 1 and 3 fail without the fix. Stage 2 passes without the fix too; it checks that strings'
echo '# that are not such names give the same results as before. Each check names the result it expects,'
echo '# shows a $ZYSQLNULL result as <$ZYSQLNULL> and an error by its mnemonic. $ZYSQLNULL is a YottaDB'
echo '# feature, so this subtest does not apply to GT.M.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1305.m .

echo '# Stage 1 : $QLENGTH, $QSUBSCRIPT and $NAME(@r,depth) of names with $ZYSQLNULL subscripts or environment'
echo '# Command : $gtm_dist/mumps -run names^ydb1305'
echo '#   expect the subscript count and subscripts of each name, and $NAME(@r,depth) to equal $NAME of the'
echo '#   same reference written directly'
echo '#   previously, each of these issued NOCANONICNAME, and a Debug build failed an assert at the first'
echo '#   $NAME(@r,depth)'
$gtm_dist/mumps -run names^ydb1305
echo

echo '# Stage 2 : the same functions on strings that are not names with a $ZYSQLNULL subscript'
echo '# Command : $gtm_dist/mumps -run others^ydb1305'
echo '#   expect NOCANONICNAME for each malformed name, and "$ZYSQLNULL" in quotes to be a string subscript'
echo '#   previously the same results, since the fix does not apply to these strings'
$gtm_dist/mumps -run others^ydb1305
echo

echo '# Stage 3 : $ZCOLLATE of a global name with a $ZYSQLNULL subscript'
echo '# Command : $gtm_dist/mumps -run gvn^ydb1305'
echo '#   expect ZYSQLNULLNOTVALID, since a global subscript cannot be $ZYSQLNULL'
echo '#   previously NOCANONICNAME'
$gtm_dist/mumps -run gvn^ydb1305
echo

echo "# Done"
