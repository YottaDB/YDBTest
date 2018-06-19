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
# Tests that if the first reference to a database is an extended referenence,
# $REFERENCE maintains the extended reference
#

$gtm_tst/com/dbcreate.csh mumps 1 >>& create.out
if ($status) then
	echo "dbcreate failed"
endif

echo "# Setting Stat Sharing ON"
$MUPIP Set -STAT -REGION DEFAULT
$DSE dump -file |& $grep gvstats |& $tst_awk '{print $5,$6,$7,$8}'
$ydb_dist/mumps -run gtm8790


$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "dbcheck failed"
endif
