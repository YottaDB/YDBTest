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
# Tests TRIGGER_MOD restricts ZBREAKS and ZSTEPS
#
cat > triggers.txt << EOF
+^X -command=set -xecute="zbreak child^gtm8842  do trigger^gtm8842"
EOF
mkdir temp
cp $ydb_dist/* temp/
setenv ydb_dist temp
echo "TRIGGER_MOD" >>& $ydb_dist/restrict.txt
chmod -w $ydb_dist/restrict.txt
#chmod -r $ydb_dist/restrict.txt
ls -l $ydb_dist/restrict.txt
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
$MUPIP trigger -triggerfile=triggers.txt
$ydb_dist/mumps -run parent^gtm8842

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
