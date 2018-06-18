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
# Tests the Update Process operates correctly when a trigger issues a NEW $ZGBLDIR
# while performing updates on other unreplicated instances
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
if ($status) then
	echo "# DB Create failed"
endif
set x=`pwd`
echo '+^X -commands=Set -xecute="NEW $ZGBLDIR"' >& triggerfile.txt
$MUPIP trigger -triggerfile=triggerfile.txt
#$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP trigger -triggerfile=$x/triggerfile.txt"
$ydb_dist/mumps -run gtm8789
$sec_shell "$sec_getenv; cd $SEC_SIDE; $ydb_dist/mumps -run ^%XCMD 'write ^X'"

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
if ($status) then
	echo "# DB Check failed"
endif
