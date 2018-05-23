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
# Test that a line length greater than 8192 bytes produces a LSEXPECTED warning
#

echo "# Generating an M file with big string"
$ydb_dist/mumps -run gtm7986

echo "# Attempting to run file"
$ydb_dist/mumps -run temp
