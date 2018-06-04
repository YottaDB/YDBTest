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
#
#

$ydb_dist/mumps -run gtm4212


$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate1.out
foreach i (228 229 230 231 232 233)
	$ydb_dist/mumps -run gtm4212 $i >>& a$i.out
	set dir = `cat a$i.out`
	mkdir -p $dir
	set j = `expr $i + 24`
	echo "# Backing up DEFAULT Region to path length $i (length of temp file is 24, so total path is $j)"
	$MUPIP BACKUP "DEFAULT" $dir >& bck$i.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck$i.outx

end

$gtm_tst/com/dbcheck.csh >>& dbcheck1.out
