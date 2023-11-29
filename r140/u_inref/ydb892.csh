#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# ----------------------------------------------------------------------"
echo "# Test that DSE INTEG -BLOCK=3 does not assert fail in an empty database"
echo "# ----------------------------------------------------------------------"

echo "# Create an empty database"
$gtm_tst/com/dbcreate.csh mumps

echo "# Run [dse integ -block=3]. Expect a DBBSIZMN error (no assert failure)"
$DSE integ -block=3

echo "# Do integ check on database"
$gtm_tst/com/dbcheck.csh

