#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Test that /tmp/yottadb/$ydb_ver has read-write-execute permissions for all users permitted to execute YottaDB'
echo ""
echo "# Invoke ydb_env_set"
. $ydb_dist/ydb_env_set
echo '. $ydb_dist/ydb_env_set'

echo ""
echo '# Get the permissions of /tmp/yottdb/$ydb_ver, which was created when ydb_env_set was called'
# Get the version of YDB from $ZYREL in mumps
ver_num=`$ydb_dist/mumps -run ^%XCMD 'write $ZYREL' | cut -d" " -f2`

$gtm_tst/com/lsminusl.csh -L /tmp/yottadb/ | grep "$ver_num" | cut -d" " -f1

echo ""
echo '# Get the permissions of $ydb_dist/libyottadb.so, which was created when yottadb was installed'
$gtm_tst/com/lsminusl.csh -L $ydb_dist | grep libyottadb.so | cut -d" " -f1
