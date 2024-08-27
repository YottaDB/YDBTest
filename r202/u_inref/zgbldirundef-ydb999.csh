#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "###########################################################################################################"
echo '# Test ZGBLDIRUNDEF error is issued when ydb_gbldir env var is undefined or set to ""'
echo "###########################################################################################################"

echo "# Run [dbcreate.csh]"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

set savegbldir = $gtmgbldir

echo
echo '# Test 1 : Global reference when [gtmgbldir] is undefined should issue a ZGBLDIRUNDEF error'
echo '# Expect a ZGBLDIRUNDEF error below'
unsetenv gtmgbldir
$gtm_dist/mumps -run %XCMD 'write ^x'

echo
echo '# Test 2 : Global reference when [gtmgbldir] is set to "" should issue a ZGBLDIRUNDEF error'
echo "# Expect a ZGBLDIRUNDEF error below"
setenv gtmgbldir ""
$gtm_dist/mumps -run %XCMD 'write ^x'

setenv gtmgbldir $savegbldir

echo
echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh >>& dbcheck.out

