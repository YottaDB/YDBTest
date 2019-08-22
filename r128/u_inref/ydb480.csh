#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that $increment() of a non-existant var or a var with a zero value that is
# incremented by a 7 digit (so is floating pt internally) value returns the correct
# value instead of returning the null string.
#
echo "Test increment() of non-existant var or var with value 0 by a 7 or more digit literal"
echo "returns the correct value and not a null value as happens without [YDB#480]."
echo
#
# Create database we need. This DB is accessed but not really updated and just so the environment exists
# so we don't both with replication on this test.
#
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
echo "Test with simple API - build executable"
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/ydb480.c -I$ydb_dist # Compile it
set save_status = $status
if (0 != $save_status) then
    echo "Build failed with status $save_status"
    exit 1
endif
$gt_ld_linker $gt_ld_option_output ydb480 $gt_ld_options_common ydb480.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& ydb480.map # Link it
set save_status = $status
if (0 != $save_status) then
    echo "Link failed with status $save_status"
    exit 1
endif
# Now run simple API test
echo
echo "Testing with simple API"
ydb480
set save_status = $status
if (0 != $save_status) then
    echo "Running ydb480 failed with status $save_status"
endif
# Now test with M code
echo
echo "Testing with M code"
rm ydb480.o # Get rid of C flavor .o so M linker doesn't get confused
$ydb_dist/yottadb -run ydb480
#
$gtm_tst/com/dbcheck.csh
