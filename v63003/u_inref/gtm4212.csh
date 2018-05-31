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

$ydb_dist/mumps -run path236^gtm4212
$ydb_dist/mumps -run path235^gtm4212
$ydb_dist/mumps -run pathge236^gtm4212
$ydb_dist/mumps -run pathle235^gtm4212

set p235 = `cat temp235.out`
set p236 = `cat temp236.out`
set ple235 = `cat temple235.out`
set pge236 = `cat tempge236.out`

mkdir -p $p235
mkdir -p $p236
mkdir -p $ple235
mkdir -p $pge236


$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate1.out
echo "# Backing up Default to length 235 path (length of temp file is 19, so total path is 254)"
$MUPIP BACKUP "DEFAULT" $p235 >& bck1.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck1.outx
echo "# Backing up Default to length 236 path (length of temp file is 19, so total path is 255)"
$MUPIP BACKUP "DEFAULT" $p236 >& bck2.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck2.outx
echo "# Backing up a Default to length <=235 path (<=254 including temp file)"
$MUPIP BACKUP "DEFAULT" $ple235 >& bck3.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck3.outx
echo "# Backing up a Default to length >=236 path (>=255 including temp file)"
$MUPIP BACKUP "DEFAULT" $pge236 >& bck4.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck4.outx
$gtm_tst/com/dbcheck.csh >>& dbcheck1.out
