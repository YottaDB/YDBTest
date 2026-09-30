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
echo '# [YDB#1286] $ZWRITE(str,1) and ydb_zwr2str_s() return the empty string for a str that is not a      #'
echo '# complete ZWRITE format string, and do not read past its end                                        #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# zwr2format() converts a ZWRITE format string to the string it represents, for $ZWRITE(str,1),'
echo '# ydb_zwr2str_s(), MUPIP LOAD and trigger definitions. It read the byte after a string that ended'
echo '# in "$", "$Z", "$ZC", "$C", or after the number in an unterminated $C( or $ZCH(. It also accepted'
echo '# strings ending in "_", in an unterminated quoted string, in an unterminated $C( or $ZCH(, or in a'
echo '# number that does not end in a digit.'
echo '#'
echo '# $EXTRACT() and $ZEXTRACT() return a string that shares memory with their source, so a prefix of a'
echo '# ZWRITE format string taken that way is followed in memory by the rest of the string, and a read past'
echo '# its end finds the byte that makes it valid. In stage 5 a read past the end gets a SIGSEGV.'
echo '#'
echo '# Without the fix, every check below prints WRONG except the controls, whose expected result is not'
echo '# the empty string, and the invalid strings "X"_$C(65)Y and _"X". In stage 5 the six strings in the'
echo '# first group each end the process with a SIGSEGV.'
echo

cp $gtm_tst/$tst/inref/ydb1286.m .
$switch_chset M >& switch_chset_m.out

echo '# Stage 1 : prefixes of a valid ZWRITE format string, taken with $EXTRACT()'
echo '# Command : $ydb_dist/yottadb -run truncated^ydb1286'
echo '#   expect "" for each prefix that ends in "$", "$Z", "$ZC", "$C" or an unterminated $C( or $ZCH(, and'
echo '#   "XA" for the complete strings'
$ydb_dist/yottadb -run truncated^ydb1286
echo

echo '# Stage 2 : strings that are not valid ZWRITE format strings on their own, and valid controls'
echo '# Command : $ydb_dist/yottadb -run invalid^ydb1286'
echo '#   expect "" for each invalid string, and the string it represents for each valid one'
$ydb_dist/yottadb -run invalid^ydb1286
echo

echo '# Stage 3 : every prefix of 2000 random ZWRITE format strings of 1 to 4 tokens, each token a quoted'
echo '#           string, a $C() or a $ZCH(), with each prefix taken with $ZEXTRACT()'
echo '# Command : $ydb_dist/yottadb -run randm^ydb1286'
echo '#   expect "" for each prefix that does not end with a complete token, or at the first " of a "" in a'
echo '#   quoted string, and the string the prefix represents for each one that does'
$ydb_dist/yottadb -run randm^ydb1286
echo

if ("TRUE" == "$gtm_test_unicode_support") then
	echo '# Stage 4 : stages 1 and 3 in UTF-8 mode, where $C() also takes code points above 255'
	echo '# Command : $ydb_dist/yottadb -run truncutf8^ydb1286 ; $ydb_dist/yottadb -run randutf8^ydb1286'
	echo '#   expect "" for the prefix "X"_$C(1234, and the same results as stage 3'
	$switch_chset "UTF-8" >& switch_chset_utf8.out
	$ydb_dist/yottadb -run truncutf8^ydb1286
	$ydb_dist/yottadb -run randutf8^ydb1286
	$switch_chset M >& switch_chset_m2.out
	echo
endif

echo '# Stage 5 : ydb_zwr2str_s() of each string placed at the end of a page that is followed by a page with'
echo '#           no access, in a child process per string'
echo '# Command : build and run ydb1286_guard.c'
echo '#   expect "" for each invalid string and no SIGSEGV, and the string it represents for each valid one'
set file = ydb1286_guard
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
./$file
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 6 : MUPIP LOAD of a ZWR file whose records hold ZWRITE format values'
echo 'YottaDB MUPIP EXTRACT' > load.zwr
echo '30-SEP-2026  12:00:00 ZWR' >> load.zwr
echo '^x(1)="X"_' >> load.zwr
echo '^x(2)="X"_$C(' >> load.zwr
echo '^x(3)="X"_$C(65)_' >> load.zwr
echo '^x(4)="X"_"Y' >> load.zwr
echo '^x(5)="a""' >> load.zwr
echo '^x(6)="X"_$C(65)' >> load.zwr
echo '# load.zwr holds :'
cat load.zwr
echo '# Command : $ydb_dist/mupip load load.zwr'
echo '#   expect a format error for each of ^x(1) to ^x(5), LOADFILERR, and only ^x(6) to be loaded'
$ydb_dist/mupip load load.zwr >& load.out
$gtm_tst/com/check_error_exist.csh load.out LOADFILERR
cat load.out
$ydb_dist/yottadb -run loadchk^ydb1286
echo

echo '# Stage 7 : $ZTRIGGER("item") of a trigger whose -delim= value is a ZWRITE format string'
echo '#   expect each -delim= value that is not a complete ZWRITE format string to be rejected with'
echo '#   "Invalid delimiter", and only the trigger with the complete one to be added'
$ydb_dist/yottadb -run trig^ydb1286
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
