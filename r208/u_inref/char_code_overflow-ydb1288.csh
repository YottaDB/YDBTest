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
echo '# [YDB#1288] $C()/$ZCH() arguments in a ZWRITE format string and trigger -pieces= values of           #'
echo '# 2147483648 or more are rejected, not wrapped around modulo 2**32                                    #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# The A2I() macro, which parses these numbers, kept going after an int overflow as long as the value'
echo '# stayed positive, so it returned the number modulo 2**32: $C(4294967361) was read as $C(65), and'
echo '# -pieces=4294967298 as -pieces=2. When the value went negative it stopped, and a debug build failed'
echo '# an assert, for example on $C(2147483713).'
echo '#'
echo '# Without the fix, the checks below of numbers that wrap to a valid code print WRONG, and on a debug'
echo '# build the checks of numbers that go negative, such as 2147483713, fail an assert instead.'
echo

cp $gtm_tst/$tst/inref/ydb1288.m .
$switch_chset M >& switch_chset_m.out

echo '# Stage 1 : $ZWRITE(str,1) of a $C() or $ZCH() with an argument too large for an int, and controls'
echo '# Command : $ydb_dist/yottadb -run zwr^ydb1288'
echo '#   expect "" for each argument of 2147483648 or more, and the character for each control'
$ydb_dist/yottadb -run zwr^ydb1288
echo

echo '# Stage 2 : $ZWRITE("$C(n)",1) for 1000 random n = k*2**32+c, with k from 1 to 2**20 and c from 0 to 255'
echo '# Command : $ydb_dist/yottadb -run random^ydb1288'
echo '#   expect "" for every n'
$ydb_dist/yottadb -run random^ydb1288
echo

if ("TRUE" == "$gtm_test_unicode_support") then
	echo '# Stage 3 : $ZWRITE(str,1) in UTF-8 mode, where $C() takes code points above 255'
	echo '# Command : $ydb_dist/yottadb -run zwrutf8^ydb1288'
	echo '#   expect "" for 2**32+1234 and 2**32+1114109, and the character for 1234 and 1114109'
	$switch_chset "UTF-8" >& switch_chset_utf8.out
	$ydb_dist/yottadb -run zwrutf8^ydb1288
	$switch_chset M >& switch_chset_m2.out
	echo
endif

echo '# Stage 4 : $QSUBSCRIPT() of a name whose subscript is a $C() with an argument too large for an int'
echo '# Command : $ydb_dist/yottadb -run qsub^ydb1288'
echo '#   expect no character for the too-large argument, and "A" for $C(65)'
$ydb_dist/yottadb -run qsub^ydb1288
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 5 : MUPIP LOAD of a ZWR file with $C() arguments too large for an int in values and subscripts'
echo 'YottaDB MUPIP EXTRACT' > load.zwr
echo '30-SEP-2026  12:00:00 ZWR' >> load.zwr
echo '^x(1)=$C(4294967361)' >> load.zwr
echo '^x($C(4294967361))=1' >> load.zwr
echo '^x(2)=$C(2147483713)' >> load.zwr
echo '^x($C(2147483713))=2' >> load.zwr
echo '^x(3)=$C(65)' >> load.zwr
echo '# load.zwr holds :'
cat load.zwr
echo '# Command : $ydb_dist/mupip load load.zwr'
echo '#   expect a format error for each value, DLRCUNXEOR and RECLOAD for each subscript, FAILEDRECCOUNT, and only'
echo '#   ^x(3) to be loaded'
$ydb_dist/mupip load load.zwr >& load.out
$gtm_tst/com/check_error_exist.csh load.out DLRCUNXEOR RECLOAD FAILEDRECCOUNT
cat load.out
$ydb_dist/yottadb -run loadchk^ydb1288
echo

echo '# Stage 6 : $ZTRIGGER("item") with -pieces= values, and pattern repeat counts in a subscript (a plain'
echo '#           count, the upper bound of a range, and a count inside an alternation), too large for an int'
echo '#   expect each to be rejected, and only the trigger with -pieces=2 to be added'
$ydb_dist/yottadb -run trig^ydb1288
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
