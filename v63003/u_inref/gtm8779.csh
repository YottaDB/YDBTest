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
$gtm_tst/com/dbcreate.csh mumps 1 >>& create.out

# Setting freeze to off initially so we can ensure the first command
# is changing the freeze status
$MUPIP FREEZE -OFF DEFAULT >>& init.out

set t1 = `date +"%b %e %H:%M:%S"`
$MUPIP FREEZE -ON DEFAULT
set t2 = `date +"%b %e %H:%M:%S"`
echo "# Verifying System received a DBFREEZEON message"
$gtm_tst/com/getoper.csh "$t1" "$t2" t1t2.txt

cat t1t2.txt |& $grep "DBFREEZEON" | $tst_awk '{print $6}'

echo "# Setting Default Region to UNFROZEN"
set t3 = `date +"%b %e %H:%M:%S"`
$MUPIP FREEZE -OFF DEFAULT
echo "# Verifying System received a DBFREEZEOFF message"
$gtm_tst/com/getoper.csh "$t2" "$t3" t2t3.txt

cat t2t3.txt |& $grep "DBFREEZEOFF" | $tst_awk '{print $6}'

$gtm_tst/com/dbcheck.csh >>& check.out
