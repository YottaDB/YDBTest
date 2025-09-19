#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that mupip rundown runs successfully even if the file pointed to by gtm_repl_instance/ydb_repl_instance does not exist."
echo "# Creating database."
$gtm_tst/com/dbcreate.csh mumps
echo "# Setting gtm_repl_instance to $gtm_dist/fake.repl"
setenv gtm_repl_instance $gtm_dist/fake.repl
echo "# Running mupip rundown."
$gtm_dist/mupip rundown -r '*'
