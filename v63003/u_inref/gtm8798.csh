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
# Tests ENDIANCVT converts the Mutex fields
#

# Setting environment variables to avoid compatibility issues
setenv gtm_test_db_format "NO_CHANGE"
setenv gtm_test_jnl "NON_SETJNL"
$gtm_tst/com/dbcreate.csh mumps 1 >>& create.out
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
$MUPIP dumpfhead -region DEFAULT >>& Dump1.out

echo "# Mutex fields before ENDIANCVT"
cat Dump1.out |& $grep mutex_spin_parms

echo ""

echo "yes" | $MUPIP ENDIANCVT mumps.dat -OVERRIDE
$MUPIP dumpfhead -region DEFAULT >>& Dump2.out

echo ""

echo "# Mutex fields after ENDIANCVT"
cat Dump2.out |& $grep mutex_spin_parms

echo "yes" | $MUPIP ENDIANCVT mumps.dat -OVERRIDE >>& reset.out

$gtm_tst/com/dbcheck.csh >>& check.out

