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
# Case for each functionality described in the release note
#

echo "# Null subscript set to never"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db.txt
endif
$ydb_dist/mupip set -region DEFAULT -Null_SUBSCRIPTS=never
$DSE dump -file|&grep "Null subscripts"
$gtm_tst/com/dbcheck.csh >& db.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat db.txt
endif

echo "# Null subscript set to existing"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db.txt
endif
$ydb_dist/mupip set -region DEFAULT -NULL_SUBSCRIPTS=existing
$DSE dump -file|&grep "Null subscripts"
$gtm_tst/com/dbcheck.csh >& db.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat db.txt
endif

echo "# Null subscript set to always"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db.txt
endif
$ydb_dist/mupip set -region DEFAULT -NULL_SUBSCRIPTS=always
$DSE dump -file|&grep "Null subscripts"
$gtm_tst/com/dbcheck.csh >& db.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat db.txt
endif

echo "# Null subscript set to an option not listed (expecting an error)"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db.txt
endif
$ydb_dist/mupip set -region DEFAULT -NULL_SUBSCRIPTS=sometimes
$gtm_tst/com/dbcheck.csh >& db.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat db.txt
endif

echo "# Null collation set to M"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db.txt
endif
$ydb_dist/mupip set -region DEFAULT -STDNULLCOLL
$DSE dump -file|&grep "Standard Null Collation"
$gtm_tst/com/dbcheck.csh >& db.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat db.txt
endif

echo "# Null collation set to GT.M"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat db.txt
endif
$ydb_dist/mupip set -region DEFAULT -NOSTDNULLCOLL
$DSE dump -file|&grep "Standard Null Collation"
$gtm_tst/com/dbcheck.csh >& db.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat db.txt
endif
