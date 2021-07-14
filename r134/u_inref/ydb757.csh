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

echo '# Running : [SET x="abcd",x=$ZYHASH(x) ZWRITE] : Expecting to not see an LVUNDEF error'
$ydb_dist/yottadb -run %XCMD 'SET x="abcd",x=$ZYHASH(x) ZWRITE x'

