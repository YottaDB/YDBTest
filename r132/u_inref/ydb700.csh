#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -----------------------------------------------------------------'
echo '# Test that Multi-line -xecute in $ztrigger() accepts trailing ">>"'
echo '# -----------------------------------------------------------------'
$gtm_tst/com/dbcreate.csh mumps
$ydb_dist/yottadb -run ydb700
echo '# Verify that 3 triggers did get loaded in the database by invoking mupip trigger -select'
$ydb_dist/mupip trigger -select -stdout
$gtm_tst/com/dbcheck.csh
