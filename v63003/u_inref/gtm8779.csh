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
# Testing for DBFREEZEON/DBFREEZEOFF message when freeze state is changed
#

echo "# Setting Default Region to FROZEN"
$gtm_tst/com/dbcreate.csh mumps 3 >>& create.out

# Setting freeze to off initially so we can ensure the first command
# is changing the freeze status
$MUPIP FREEZE -OFF DEFAULT >>& init1.out
$MUPIP FREEZE -OFF AREG >>& init2.out
$MUPIP FREEZE -ON BREG >>& init3.out
set randstring = "aaaaaaaaaaaaaaaaaaaaaaaa"
set t1 = `date +"%b %e %H:%M:%S"`
# Sleep commands to ensure a difference in time of at least 1 second so getoper.csh
# will catch the message every time
$MUPIP FREEZE -ON DEFAULT
set t2 = `date +"%b %e %H:%M:%S"`
$ydb_dist/mumps -run ^%XCMD '$ZSYSLOG("aaaaaaaaaaaaaa")'
echo "# Verifying System received a DBFREEZEON message"
$gtm_tst/com/getoper.csh "$t1" "$randstring" t1t2.txt

cat t1t2.txt |& $grep "DBFREEZEON"

echo "# Setting Default Region to UNFROZEN"
$MUPIP FREEZE -OFF DEFAULT
set t3 = `date +"%b %e %H:%M:%S"`
echo "# Verifying System received a DBFREEZEOFF message"
$gtm_tst/com/getoper.csh "$t2" "$t3" t2t3.txt

cat t2t3.txt |& $grep "DBFREEZEOFF" | $tst_awk '{print $6}'

$gtm_tst/com/dbcheck.csh >>& check.out
