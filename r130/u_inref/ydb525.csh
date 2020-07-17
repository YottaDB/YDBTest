#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# This tests for the presence of bug ydb525 which involves $io incorrectly'
echo '# being set to $principal after a SILENT^%RSEL. The test verifies that $io'
echo '# is correctly set to a file both before and after the SILENT^%RSEL.'
$ydb_dist/yottadb -r ydb525
