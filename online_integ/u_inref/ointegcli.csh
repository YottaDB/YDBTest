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
# This module is derived from FIS GT.M.
#################################################################

# This subtest verifies that mupip online integ reports an error if it is run on a V4 database

$gtm_tst/com/dbcreate.csh mumps 4

$GTM << EOF
set ^a=3
set ^b=5
h
EOF

$echoline
echo "# regular integ - file specified and -online"
echo "# mupip integ -file -online mumps.dat"
$echoline
set mupip_log = "mupip_log1.log"
$MUPIP integ $FASTINTEG -file -online mumps.dat >&! $mupip_log

$echoline
echo "# Verify CLIERR error is present."
$echoline
$gtm_tst/com/check_error_exist.csh $mupip_log CLIERR

$echoline
echo "# regular integ -online and -tn_reset"
echo "# mupip integ -online -tn_reset -r DEFAULT"
$echoline
set mupip_log = "mupip_log2.log"
$MUPIP integ $FASTINTEG -online -tn_reset -r DEFAULT >&! $mupip_log

$echoline
echo "# Verify CLIERR error is present."
$echoline
$gtm_tst/com/check_error_exist.csh $mupip_log CLIERR

$echoline
echo "# regular integ - file specified"
echo "# mupip integ -file mumps.dat"
$echoline
set mupip_log = "mupip_log3.log"
$MUPIP integ $FASTINTEG -file mumps.dat >&! $mupip_log

$echoline
echo "# regular integ"
echo "# mupip integ -noonline -r DEFAULT"
$echoline
set mupip_log = "mupip_log4.log"
$MUPIP integ $FASTINTEG -noonline -r DEFAULT >&! $mupip_log

$echoline
echo "# regular integ"
echo "# mupip integ -r DEFAULT"
$echoline
set mupip_log = "mupip_log5.log"
$MUPIP integ $FASTINTEG -r DEFAULT >&! $mupip_log

$echoline
echo "# online integ"
echo "# mupip integ -online -r DEFAULT"
$echoline
set mupip_log = "mupip_log7.log"
$MUPIP integ $FASTINTEG -online -r DEFAULT >&! $mupip_log

$echoline
echo "# online integ with preserve"
echo "# mupip integ -online -preserve -r DEFAULT"
$echoline
set mupip_log = "mupip_log8.log"
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log

# Verify ydb_snapshot files exist
ls ydb_snapshot*

$echoline
echo "# online integ analyze"
echo "# mupip integ -online -analyze"
$echoline
set mupip_log = "mupip_log6.log"
$MUPIP integ $FASTINTEG -online -analyze=`ls ydb_snapshot_*` >&! $mupip_log

$echoline
echo "# regular integ - all regions"
echo "# mupip integ -r *"
$echoline
set mupip_log = "mupip_log9.log"
$MUPIP integ $FASTINTEG -r "*" >&! $mupip_log

$echoline
echo "# regular integ - multiple listed regions"
echo "# mupip integ -r AREG BREG CREG"
$echoline
set mupip_log = "mupip_log10.log"
$MUPIP integ $FASTINTEG -r "AREG,BREG,CREG" >&! $mupip_log

$gtm_tst/com/dbcheck.csh
