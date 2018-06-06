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
# Tests $select produces a syntax error for omitted colons after
# a literal true is encountered
#

echo '# Running "write $select(1:0,0)" in mumps script'
$ydb_dist/mumps -run gtm8780
