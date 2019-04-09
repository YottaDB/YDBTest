#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


echo "Compiling a file without error"
$gtm_dist/mumps $gtm_tst/$tst/inref/gtm7281correct.m >&! error_correct_file.txt
echo "Return value:" $?

echo "Compiling both a file with error and without error"
$gtm_dist/mumps $gtm_tst/$tst/inref/gtm7281incorrect.m $gtm_tst/$tst/inref/gtm7281correct.m >&! error_both_files.txt
echo "Return value:" $?
$gtm_tst/com/check_error_exist.csh error_both_files.txt "%YDB-E-INVCMD" >&! /dev/null

echo "Making sure xargs continues calling compiler on compile error"
echo "$gtm_tst/$tst/inref/gtm7281incorrect.m $gtm_tst/$tst/inref/gtm7281correct.m" | xargs $gtm_dist/mumps >& error_xargs.txt
$gtm_tst/com/check_error_exist.csh error_xargs.txt "%YDB-E-INVCMD" >&! /dev/null
# xargs should not have quitted
$tail -n 1 error_xargs.txt | $grep "xargs"
