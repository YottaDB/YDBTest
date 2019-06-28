#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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

echo '# MUPIP SET accepts -KEY_SIZE or -RESERVED_BYTES and -RECORD_SIZE in the same command; beginning with V6.0-000 they are not incompatible, but MUPIP SET continued to give an error when they were combined'

$gtm_tst/com/dbcreate.csh yottadb
setenv ydb_gbldir yottadb.gld

echo '# Testing -KEY_SIZE=999 and -RECORD_SIZE=999 together'
$ydb_dist/mupip set -KEY_SIZE=999 -RECORD_SIZE=999 -region "*"

echo; echo '# Testing -RESERVED_BYTES=999 and -RECORD_SIZE=999 together'
$ydb_dist/mupip set -RESERVED_BYTES=999 -RECORD_SIZE=999 -region "*"

$gtm_tst/com/dbcheck.csh
