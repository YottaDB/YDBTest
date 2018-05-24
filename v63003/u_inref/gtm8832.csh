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
# Tests if string literal evaluated as a number greater than or
# equal to 1E47 produces a NUMOFLOW error

echo "# Evaluating for 1E46 and 1E47"
$ydb_dist/mumps -run gtm8832
