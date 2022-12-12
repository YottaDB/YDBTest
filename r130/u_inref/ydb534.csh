#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# -------------------------------------------------------------------------------------------------------"
echo "# Test that SIGABRT generates core (default action for SIGABRT) in SimpleThreadAPI mode without any hangs"
echo "# -------------------------------------------------------------------------------------------------------"

set filename = "ydb534"

echo "# Create database file (needed for ydb_tp_st() call"
$gtm_tst/com/dbcreate.csh mumps

echo ""
echo "# Compile and link C file [r130/inref/$filename.c] into executable [./$filename]"
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/$filename.c -I $ydb_dist -g
$gt_ld_linker $gt_ld_option_output $filename $gt_ld_options_common $filename.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif

echo ""
echo "# Invoke the executable [./$filename] which should invoke do_abort() function and create a core file"
`pwd`/$filename

echo ""
echo "# Verify core file was created and does show do_abort() invocation in $filename.c in the C-stack trace"
ls -1 core* >& /dev/null
if (0 != $status) then
	echo "FAIL : Core file expected but not found"
else
	echo "PASS: Core file expected and found"
	set corename=`ls -1 core*`
	set newcorename = hidden_expected_core_$corename
	mv $corename $newcorename
	$gtm_tst/com/get_dbx_c_stack_trace.csh $newcorename `pwd`/$filename >& stacktrace.out
	sed 's/(.*)//g;s/ 0x.* in//g' stacktrace.out | $grep "do_abort"
endif

echo ""
echo "# Verify YDB_FATAL_ERROR* file is created (remove it afterwards to avoid test framework from detecting it)"
set fatalerrorfile = `ls -1 YDB_FATAL_ERROR*`
if (-e $fatalerrorfile) then
    echo "PASS: YDB_FATAL_ERROR file expected and found"
    rm $fatalerrorfile
else
    echo "FAIL: YDB_FATAL_ERROR file expected but not created"
endif

echo ""
echo "# Ensure db still integs clean"
$gtm_tst/com/dbcheck.csh

