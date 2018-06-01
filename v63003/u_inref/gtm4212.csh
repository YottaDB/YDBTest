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

$ydb_dist/mumps -run path230^gtm4212
$ydb_dist/mumps -run path231^gtm4212
$ydb_dist/mumps -run pathge231^gtm4212
$ydb_dist/mumps -run pathle230^gtm4212

set p231 = `cat temp231.out`
set p230 = `cat temp230.out`
set pge231 = `cat tempge231.out`
set ple230 = `cat temple230.out`

mkdir -p $p231
mkdir -p $p230
mkdir -p $pge231
mkdir -p $ple230


$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate1.out
echo "# Backing up Default to length 230 path (length of temp file is 24, so total path is 254)"
$MUPIP BACKUP "DEFAULT" $p230 >& bck1.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck1.outx
echo "# Backing up Default to length 231 path (length of temp file is 24, so total path is 255)"
$MUPIP BACKUP "DEFAULT" $p231 >& bck2.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck2.outx
echo "# Backing up a Default to length <=230 path (<=254 including temp file)"
$MUPIP BACKUP "DEFAULT" $ple230 >& bck3.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck3.outx
echo "# Backing up a Default to length >=231 path (>=255 including temp file)"
$MUPIP BACKUP "DEFAULT" $pge231 >& bck4.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck4.outx
$gtm_tst/com/dbcheck.csh >>& dbcheck1.out
