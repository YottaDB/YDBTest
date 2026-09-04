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
#	$1	value to give $ydb_tmp, the directory whose creation is under test
#	$2	directory to use as $HOME (and, under it, $ydb_dir). Optional: only the stage that
#		lets ydb_env_set run to completion needs one, so that the environment it builds
#		lands in the subtest directory instead of the invoking user's home directory.
#
# The global directory environment variables are unset because the subtest framework points them at
# a .gld file that need not exist. %YDBENV would then stop at NOTAPATH (GLDEnsure) rather than at the
# "mkdir -p" this subtest is about, and the stage that runs to completion would never get there at
# all. With them unset, %YDBENV falls back to $ydb_dir, which is $2.

unset ydb_gbldir gtmgbldir gtm_gbldir ydb_rel gtmver gtmdir

ydb_tmp="$1"
export ydb_tmp
if [ -n "$2" ] ; then
	HOME="$2"
	ydb_dir="$2/.yottadb"
	export HOME ydb_dir
fi

echo "# Sourcing ydb_env_set with ydb_tmp=$ydb_tmp"
. $ydb_dist/ydb_env_set
exit_status=$?
echo "Exit status = $exit_status"
