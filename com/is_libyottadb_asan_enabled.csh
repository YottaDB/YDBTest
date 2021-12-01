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

# Sets the env var "gtm_test_libyottadb_asan_enabled" to 1 if libyottadb.so was linked with libasan.so and to 0 otherwise.

# Because the test framework can be used on a pure GT.M build too, we need to account for the
# fact that libyottadb.so does not exist but libgtmshr.so exists. And therefore the below
# check is done on libgtmshr.so (since libgtmshr.so exists even in YottaDB builds as a soft link
# to libyottadb.so).

set asanlib = `ldd $gtm_exe/libgtmshr.so | grep libasan`
if ("" == "$asanlib") then
	setenv gtm_test_libyottadb_asan_enabled 0
else
	setenv gtm_test_libyottadb_asan_enabled 1
endif

