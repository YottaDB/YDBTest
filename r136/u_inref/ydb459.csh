#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# ------------------------------------------------------------------------------------"
echo "# Test MUPIP RUNDOWN reports REPLINSTACC error if replication instance file is missing"
echo "# ------------------------------------------------------------------------------------"

echo "# Create database using dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps

echo "# Set gtm_repl_instance env var to [missing.repl], a non-existent file"
setenv gtm_repl_instance missing.repl

echo '# Run [mupip rundown -reg "*"]. Expect REPLINSTACC error.'
$MUPIP rundown -reg "*"

echo "# Verify database using dbcheck.csh"
$gtm_tst/com/dbcheck.csh

