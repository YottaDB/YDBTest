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

echo "# This test checks that setting zstatus to strings that would be exponential numbers and then writing it"
echo "# results in the string being written as expected not a %YDB-E-NUMOFLOW error. In upstream versions prior to"
echo "# V6.3-011 and YottaDB versions based on those versions, this would result in a %YDB-E-NUMOFLOW but the string"
echo "# could still be read by doing a zshow i."

$ydb_dist/mumps -run %XCMD 'for x="1e46","1e47","1e48","1e50","1e150","1e999","1e999999" set $zstatus=x write $zstatus,!'
$ydb_dist/mumps -run %XCMD 'for x="1E46","1E47","1E48","1E50","1E150","1E999","1E999999" set $zstatus=x write $zstatus,!'
