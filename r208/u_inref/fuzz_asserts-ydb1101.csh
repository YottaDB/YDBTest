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
echo '# [YDB#1101] Error paths found by fuzz testing that failed asserts in a Debug build                  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage issued the error expected, or none, in a Release build, but failed an assert in a Debug'
echo '# build.'
echo '#'
echo '# The direct mode stages run their lines in a new process, and check their output for the lines'
echo '# named, and for no fatal error.'
echo

set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1101dm"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : $$ followed by an unterminated string literal where a routine name is expected'
echo '#   expect RTNNAME for each line'
echo '#   previously an assert in extern_func.c in a Debug build'
$dm fadollar RTNNAME
echo

echo '# Stage 2 : pattern indirection followed by an unterminated string literal'
echo '#   expect EXPR'
echo '#   previously an assert in indirection.c in a Debug build'
$dm fapat EXPR
echo

echo '# Stage 3 : name indirection of a string that has a non-ASCII character after an at-sign'
echo '#   expect EXPR'
echo '#   previously an assert in indirection.c in a Debug build'
$dm faatsign EXPR
echo

echo '# Stage 4 : SET $ZWRTACn followed by an unterminated string literal'
echo '#   expect VAREXPECTED'
echo '#   previously an assert in m_set.c in a Debug build'
$dm fazwrtac VAREXPECTED
echo

echo '# Stage 5 : $VIEW() with more than two arguments'
echo '#   expect the arguments after the second to be ignored'
echo '#   previously an assert in op_fnview.c in a Debug build'
$dm faview
echo

echo '# Stage 6 : SET $ECODE to a value 32769 bytes long'
echo '#   expect SETECODE, and the next line to run'
echo '#   previously an assert in ecode_add.c in a Debug build'
$dm faecode SETECODE
echo

echo '# Stage 7 : MUPIP JOURNAL -ROLLBACK -BACKWARD -ONLINE with no replication instance file defined'
echo '#   expect REPLINSTUNDEF and MUNOACTION'
echo '#   previously an assert in mur_close_files.c in a Debug build'
source $gtm_tst/com/unset_ydb_env_var.csh ydb_repl_instance gtm_repl_instance
echo '# Command : $gtm_dist/mupip journal -rollback -backward -online "*"'
$gtm_dist/mupip journal -rollback -backward -online "*" >& rollback.out
if ({ $grep -q -- "-F-" rollback.out }) then
	echo "FAIL : MUPIP issued a fatal error. See rollback.out"
else
	echo "PASS : MUPIP issued no fatal error"
endif
$gtm_tst/com/check_error_exist.csh rollback.out REPLINSTUNDEF MUNOACTION
echo

echo '# Stage 8 : ZCOMPILE with $ZCOMPILE set to " -c", which matches -CROSS_REFERENCE'
echo '#   expect the object file and the listing to be written'
echo '#   previously an assert in list_file.c in a Debug build'
$dm zccross
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
