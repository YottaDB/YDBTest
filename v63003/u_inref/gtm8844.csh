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


# Lack permissions to write to the $ydb_dist directory, so we are creating a temp directory
# and copying all files from $ydb_dist to temp, changing the ydb_dist environment variable
# and putting restrict.txt in temp
mkdir temp
cp $ydb_dist/* temp/
set ydb_dist0=$ydb_dist
setenv ydb_dist temp
cat > $ydb_dist/restrict.txt << EOF
ZHALT
HALT
EOF
chmod -w $ydb_dist/restrict.txt

# Creating trigger file
cat > trigger.txt << EOF
+^X -command =set -xecute="do zgotofn^gtm8844"
EOF

echo "# Running functions that violate out restrictions, expect a RESTRICTEDOP error and then GTM_FATAL FILE"
echo "# -------------------------------------------------------------------------------------------"
echo "# Two consecutive halts"
$ydb_dist/mumps -run haltfn^gtm8844
echo "# -------------------------------------------------------------------------------------------"
echo "# Two consecutive zhalts"
$ydb_dist/mumps -run zhaltfn^gtm8844
echo "# -------------------------------------------------------------------------------------------"
echo ""
echo ""
echo "# Confirming ZHALT,ZGOTO 0 produces an error in the shell"
$ydb_dist/mumps -run zgotofn^gtm8844
echo "status after zgotofn=$status"
echo "# -------------------------------------------------------------------------------------------"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
$MUPIP trigger -triggerfile=trigger.txt
$ydb_dist/mumps -run ^%XCMD "set ^X=1"
$ydb_dist/mumps -run ^%XCMD "write ^X"
$sec_shell "cd $SEC_SIDE; $ydb_dist0/mumps -run ^%XCMD ""write ^X"""
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
