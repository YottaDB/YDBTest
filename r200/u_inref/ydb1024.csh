#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test of YDB#1024. See https://gitlab.com/YottaDB/DB/YDB/-/issues/1024#description for test M program details."
echo "# The below test used to assert fail in io_open_try.c without the code fixes to YDB#1024."

$ydb_dist/yottadb -run ydb1024

