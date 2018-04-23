#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

setenv gtm_test_jnl SETJNL

$gtm_tst/com/dbcreate.csh mumps

echo "#  journal extract with single / for journal file"
$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl

echo "#  journal extract with multiple / for journal file"
$MUPIP journal -extract -noverify -detail -for -fences=none .///mumps.mjl

echo "#  journal extract with single / for journal file and multiple / for extract file"
$MUPIP journal -extract=.///extract.mjf -noverify -detail -for -fences=none mumps.mjl

echo "#  journal extract with multiple / for journal file and multiple / for extract file"
$MUPIP journal -extract=.///extract.mjf -noverify -detail -for -fences=none .///mumps.mjl

$gtm_tst/com/dbcheck.csh



