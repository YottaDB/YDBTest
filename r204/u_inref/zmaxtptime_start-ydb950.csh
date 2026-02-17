#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "---------------------------------------------------------------------"
echo "# The code for this test is from"
echo "# https://gitlab.com/YottaDB/DB/YDB/-/issues/950#description"
echo "# Before GT.M V7.0-001, this used to assert fail"
echo "# Now this tests to ensure that that assert failure"
echo "# that would happen with ztrap is no longer a problem."
echo "---------------------------------------------------------------------"
echo
echo "# Run [mumps -run ydb950]"
$gtm_dist/mumps -run ydb950
