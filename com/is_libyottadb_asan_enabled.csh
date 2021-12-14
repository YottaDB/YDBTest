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
	# With GCC, we link asan dynamically. But with CLANG, we link asan statically. This is the default and recommended
	# (see https://stackoverflow.com/a/47022141 for detail) option. So check for statically linked asan symbols too.
	# https://stackoverflow.com/a/47705420 suggests a grep for "asan".
	# But that seems generic (and might give us false positives) so we search for a specific "__asan_init" symbol.
	set asan_init_symbol = `nm -an $gtm_exe/libgtmshr.so | grep __asan_init`
	if ("" == "$asan_init_symbol") then
		setenv gtm_test_libyottadb_asan_enabled 0
		setenv gtm_test_asan_compiler ""
	else
		setenv gtm_test_libyottadb_asan_enabled 1
		# ASAN was found through nm. So it must be linked with CLANG.
		# Inform caller of this through the below env var.
		setenv gtm_test_asan_compiler "clang"
	endif
else
	setenv gtm_test_libyottadb_asan_enabled 1
	# ASAN was found through ldd. So it must be linked with GCC.
	# Inform caller of this through the below env var.
	setenv gtm_test_asan_compiler "gcc"
endif

