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
# Testing YottaDB can support fractional timeout values to the millisecond for
# LOCK, OPEN and $gtm_tpnotacidtime
# Not testing READ since it is demonstrated in r120/readtimeout subtest, or JOB which
# is logistically too complicated to test
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Testing fractional timeout for lock"
$ydb_dist/mumps -run locktimeout^gtm5250
echo ""
echo "# Testing fractional timeout for open"
$ydb_dist/mumps -run opentimeout^gtm5250
echo ""
setenv gtm_tpnotacidtime .123
set t = `date +"%b %e %H:%M:%S"`
sleep 1
echo '# Testing fractional timeout for $gtm_tpnotacidtime (Expect a TPNOTACID message in the syslog)'
$ydb_dist/mumps -run tpnotacid^gtm5250
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
$grep TPNOTACID getoper.txt |& $tst_awk '{print substr($0,40,118)}'
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
