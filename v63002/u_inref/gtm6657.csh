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
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Disabling Journaling on the Database"
$MUPIP set -region default -journal=disable
echo "# Backing up Database with -BKUPDBJNL=OFF"
$MUPIP BACKUP -BKUPDBJNL=OFF default backup

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
