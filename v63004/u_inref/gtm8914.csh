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

echo "# Create a 3 region DB with gbl_dir mumps.gld and regions DEFAULT, AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log_1.txt

echo ''
echo '# Disable sharing for BREG'
$MUPIP set -NOSTAT  -reg "BREG" #>>& dbcreate_log.txt

echo '# Run gtm8914'
$ydb_dist/mumps -run gtm8914

echo '# Shut down the DB and backup necessary files to sub directory'
$gtm_tst/com/dbcheck.csh >>& dbcreate_log_1.txt
$gtm_tst/com/backup_dbjnl.csh dbbkup1 "*.gld *.mjl* *.mjf *.dat" cp nozip

