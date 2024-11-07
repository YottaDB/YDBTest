#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

setenv gtm_test_disable_randomdbtn	# to avoid variable tn number in %YDB-I-BACKUPTN message in reference file

$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif

setenv gtm_white_box_test_case_enable   1
setenv gtm_white_box_test_case_number   403	# WBTEST_YDB_STATICPID so FILEPARSE error due to temporary file name length
						# (which includes pid) occurs at deterministic target backup directory path length.

foreach i (222 223 224 225 226 227)
	$ydb_dist/mumps -run gtm4212 $i >>& a$i.out
	set dir = `cat a$i.out`
	mkdir -p $dir
	set j = `expr $i + 1 + 20 + 1 + 9`	# + 1 + 1 for leading "/" before tempdir and file name
	echo "# Backing up DEFAULT Region to path length $i (length of temp dir is 20, file name is mumps.dat, so total path is $j)"
	$MUPIP BACKUP "DEFAULT" $dir >& bck$i.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck$i.outx

end

unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_enable

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
