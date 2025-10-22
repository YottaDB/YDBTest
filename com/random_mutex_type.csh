#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f

# This script sets the "mutex_type" field in the database file header of a random list of regions (in the current gld
# pointed to by "gtmgbldir" env var) to a random value of YDB, PTHREAD or ADAPTIVE. This script does this random set
# only if the "ydb_test_mutex_type" env var is set by the test framework to the value RANDOM.

if (! $?ydb_test_mutex_type) then
	exit 0
endif

if ("RANDOM" != $ydb_test_mutex_type) then
	exit 0
endif

set reglist = `$gtm_dist/mumps -run randomreglist^getregls`
set mutextype = `$gtm_dist/mumps -run randomMutexType`

set cmd = "$gtm_dist/mupip set -mutex_type=$mutextype -reg $reglist"
echo "# `date` : Running [$cmd]"
set noglob	# to avoid tcsh from doing file name substitution in case $reglist evaluates to "*"
$cmd
unset noglob

