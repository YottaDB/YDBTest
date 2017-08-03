#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cp $gtm_tst/$tst/inref/validtriggersutf8.trg testxecuteunicode.trg
setenv test_specific_trig_file "$PWD/testxecuteunicode.trg"
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192

# this test sets the same trigger with and without the above env var
# unset gtm_gvdupsetnoop to allow duplicate sets
unsetenv gtm_gvdupsetnoop

# set this so that unicode numbers are matched by numeric pattern matches
setenv gtm_patnumeric UTF-8

$echoline
echo "Unicode subscript matching"
$gtm_exe/mumps -run testxecuteunicode

# do this so that the compound pattern matches for numerics don't work
echo "Disable Unicode numeric pattern matching"
unsetenv gtm_patnumeric
$gtm_exe/mumps -run patterns^testxecuteunicode
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh -extract
