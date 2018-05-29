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
# Test that a line length greater than 8192 bytes produces a LSEXPECTED warning
#


echo '# Creating database, setting defer time to 0'
$gtm_tst/com/dbcreate.csh mumps 1
#$MUPIP set -region DEFAULT -replication=on
$MUPIP replicate -RECEIVER -START -LOG=temp.log -LISTENPORT=1234 -LOG_INTERVAL=0
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt




