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
#
# ydb_env_set is a POSIX shell script that has to be SOURCED, so it cannot be invoked from the tcsh
# that runs the subtest. This script is the sh wrapper that sources it.
#
#	$1	value to give $ydb_dir, the directory of the environment that ydb_env_set creates or uses
#
# ydb_env_set reads ./gdedefaults, if there is one, from the current directory, which the caller
# chooses.
#
# The global directory environment variables are unset because the subtest framework points them at a
# global directory of its own. With them unset, %YDBENV uses $ydb_dir/$ydb_rel/g/yottadb.gld, where
# $ydb_rel depends on the YottaDB release, so this script prints the $ydb_gbldir that ydb_env_set sets.

unset ydb_gbldir gtmgbldir gtm_gbldir ydb_rel gtmver gtmdir

ydb_dir="$1"
export ydb_dir

echo "# Sourcing ydb_env_set with ydb_dir=$ydb_dir"
. $ydb_dist/ydb_env_set
exit_status=$?
echo "Exit status = $exit_status"
echo "ydb_gbldir = $ydb_gbldir"
