#!/usr/local/bin/tcsh -f
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
#

echo "# Test that OPEN of /dev/null correctly reads device parameters (no garbage-reads/overflows)"
echo "# Verify ZSHOW D output does not incorrectly list EXCEPTION parameter as having been specified for /dev/null"
echo "# Also check that a READ command does not issue an incorrect %YDB-E-CMD error"

$GTM << GTM_EOF
do ^ydb951
GTM_EOF

