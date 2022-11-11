#################################################################
#								#
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo "# Invoke ydb_env_set"
. $ydb_dist/ydb_env_set
exit_status=$?

echo "# Expect non-zero exit status due to above error"
echo "Exit status = $exit_status"

