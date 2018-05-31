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
$switch_chset UTF-8
echo '# Testing VIEW "[NO]STATSHARE"[:<region-list>]'

echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate_log_1.txt
echo ''

echo '# Run gtm8923.m to test WRITE * and READ * commands'
$ydb_dist/mumps -run gtm8923

echo '# Shut down the DB '
$gtm_tst/com/dbcheck.csh >>& dbcreate_log_1.txt
