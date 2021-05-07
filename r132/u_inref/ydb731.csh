#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

$echoline
echo 'YDB#731 : Test $VIEW("WORDEXP")'
$echoline

# The test reference file relies on an env var with a known fixed length. Hence the below env var set before invoking the M program.
setenv envSpcfc "/a12/b123456/c12345678/d12"

$ydb_dist/yottadb -run ydb731

