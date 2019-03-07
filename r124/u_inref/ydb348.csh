#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "----------------------------------------------------------------------------------------------------------------------"
echo "ydb348a : Test that OPEN of a SOCKET that was closed after a TPTIMEOUT error (during a SOCKET READ) does not GTMASSERT"
echo "----------------------------------------------------------------------------------------------------------------------"
$ydb_dist/mumps -run ydb348a
# Wait for child to terminate before proceeding to next test
$ydb_dist/mumps -run ^%XCMD 'do ^waitforproctodie(^child1)'

echo ""
echo "------------------------------------------------------------------------------------------------------------------------------"
echo 'ydb348b : Test that OPEN of a SOCKET that was closed inside $ZINTERRUPT (during a SOCKET READ) issues ZINTRECURSEIO error'
echo "          Note that this error showed up even before #348 fixes so this is not a regression test but is an error codepath test"
echo "------------------------------------------------------------------------------------------------------------------------------"
$ydb_dist/mumps -run ydb348b
# Wait for child to terminate before proceeding to next test
$ydb_dist/mumps -run ^%XCMD 'do ^waitforproctodie(^child2)'

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
