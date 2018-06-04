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
#

$gtm_tst/com/dbcreate.csh mumps 1 >>& create.out
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
echo "yes" | $MUPIP ENDIANCVT mumps.dat -OVERRIDE -OUTDB=out.dat
$DSE dump -file
echo "done"
$gtm_tst/com/dbcheck.csh >>& check.out

