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

$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Uploading triggerfile"
cat > triggers.txt << EOF
+^X -command=set -name=triggered -xecute="do trigger^gtm8842"
EOF
$MUPIP trigger -triggerfile=triggers.txt


echo "# Running test without restrict.txt (to show restricting TRIGGER_MOD is necessary)"
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt
$ydb_dist/mumps -run parent^gtm8842


echo "# Running test with write permissions on restrict.txt (to show restrict.txt must have readonly access)"
echo "TRIGGER_MOD" >>& $ydb_dist/restrict.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run parent^gtm8842


echo "# Running test without write permissions on restrict.txt (should work as described in the release note)"
chmod -w $ydb_dist/restrict.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run parent^gtm8842
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
