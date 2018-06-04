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
# Tests MUPIP JOURNAL -EXTRACT='-stdout' appropriately handles
# its termination

source $gtm_tst/com/gtm_test_setbeforeimage.csh

$gtm_tst/com/dbcreate.csh mumps 1 >>& create1.out
foreach i (`seq 1 1 500000`)
	$ydb_dist/mumps -run ^%XCMD "set ^X($i)=1"
end
$ydb_dist/mumps -run ^%XCMD "zwrite ^X"
echo "Backing up"
$MUPIP Journal -EXTRACT='-stdout' -BACKWARD mumps.mjl
$gtm_tst/com/dbcheck.csh >>& check1.out
