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
echo '# Testing $S[ELECT](<TRUE>:<expr>,<GLBL references>)'
echo ''

echo "# Create a DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo '# Run gtm8903.m'
$ydb_dist/mumps -run gtm8903

echo '# Shut down the DB '
$gtm_tst/com/dbcheck.csh >>& dbcreate_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcreate_log.txt
endif
