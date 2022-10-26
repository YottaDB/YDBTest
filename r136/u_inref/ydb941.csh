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

echo "# Run dbcreate.csh (creates mumps.gld)"
$gtm_tst/com/dbcreate.csh mumps

echo "# Take a copy of mumps.gld into copy.gld"
cp mumps.gld copy.gld

echo '# Test that ydb_cur_gbldir env var is not set when SET $ZGBLDIR is not done'
$ydb_dist/yottadb -run %XCMD 'zsystem "env | grep gbldir"'

echo '# Test ydb_cur_gbldir env var when SET $ZGBLDIR="" is done'
$ydb_dist/yottadb -run %XCMD 'set $zgbldir="" zsystem "env | grep gbldir"'

foreach name (mumps copy)
	echo '# Test ydb_cur_gbldir env var when SET $ZGBLDIR="'$name'.gld" is done'
	$ydb_dist/yottadb -run %XCMD 'set $zgbldir="'$name'.gld" zsystem "env | grep gbldir"'

	echo '# Test ydb_cur_gbldir env var when SET $ZGBLDIR="'`pwd`'/'$name'.gld" is done'
	if ("mumps" == "$name") then
		echo '# Note: When SET $ZGBLDIR is done to full path of ydb_gbldir/gtmgbldir, then ydb_cur_gbldir env var is'
		echo '# not set. This is because it is exactly the same full path value as ydb_gbldir/gtmgbldir.'
	endif
	$ydb_dist/yottadb -run %XCMD 'set $zgbldir="'`pwd`'/'$name'.gld" zsystem "env | grep gbldir"'
end

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh

