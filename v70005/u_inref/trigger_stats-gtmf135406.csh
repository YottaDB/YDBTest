#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# Make sure that ydb stats count the number of triggers invoked'
echo '# for each type of trigger: SET, KILL, and ZTRIGGER'
echo
echo "# Create 3 SETs (STG), 2 KILLs (KTG), and one ZTRIGGER (ZTG)"

$gtm_tst/com/dbcreate.csh mumps >>& dbcreate.out || echo "DB Create Failed, Output Below" | cat - dbcreate.out

$gtm_exe/mumps -run triggerStats

$gtm_tst/com/dbcheck.csh >>& dbcheck.out || echo "DB Check Failed, Output Below" | cat - dbcheck.out
