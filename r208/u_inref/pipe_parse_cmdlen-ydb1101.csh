#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#-------------------------------------------------------------------------------------------------#"
echo '# [#1101] PIPE OPEN with PARSE bounds the copy of an over-long unresolvable command word           #'
echo "#-------------------------------------------------------------------------------------------------#"
echo

# No special allocator setting is needed here. The buffer that used to be overrun is on the stack, so a
# long enough command word walks off the end of it: in a pro image that is a SIG-11 (and a core file,
# which errors.csh reports), and in a dbg image the assert that used to guard the copy fires. Either
# way the failure lands in the subtest log and the reference comparison catches it.
echo "## Run [ydb1101pipe] routine"
$ydb_dist/yottadb -run ydb1101pipe
