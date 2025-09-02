#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test of GVDBGNAKEDMISMATCH errors from MERGE and LOCK command'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "## Test 1: No GVDBGNAKEDMISMATCH error from sr_port/m_merge.c"
echo "# Run [ydb665a.m] and confirm no GVDBGNAKEDMISMATCH error is issued. Expect no output in this case."
echo "# Previously, this would issue a GVDBGNAKEDMISMATCH error from sr_port/m_merge.c."
echo "# See the following discussion for source program: https://gitlab.com/YottaDB/DB/YDB/-/issues/665#note_2730583550"
$gtm_dist/mumps -run ydb665a
echo

echo "## Test 2: No GVDBGNAKEDMISMATCH error from sr_port/m_lock.c"
echo "# Run [ydb665b.m] and confirm no GVDBGNAKEDMISMATCH error is issued. Expect no output in this case."
echo "# Previously, this would issue a GVDBGNAKEDMISMATCH error from sr_port/m_lock.c."
echo "# See the following discussion for source program: https://gitlab.com/YottaDB/DB/YDB/-/issues/665#note_2707941795"
$gtm_dist/mumps -run ydb665b

$gtm_tst/com/dbcheck.csh >& dbcheck.out
