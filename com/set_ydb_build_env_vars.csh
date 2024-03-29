#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Need to run this script locally and remotely (in case of a multi-host test) to set env vars related to the
# YottaDB build on that particular host. For example, if the YottaDB build was done with gcc or clang, if it
# was built with ASAN or not.

source $gtm_tst/com/is_libyottadb_asan_enabled.csh
source $gtm_tst/com/set_asan_other_env_vars.csh	# sets a few other associated asan env vars

# Set env var that indicates whether YottaDB was built with GCC or CLANG
set clangver = `strings $gtm_exe/libgtmshr.so |& grep 'clang version' | head -1`
if ("" != "$clangver") then
	setenv gtm_test_yottadb_compiler "CLANG"
	# [source $gtm_tools/gtm_env.csh] would have already set gt_cc_compiler and gt_ld_linker to gcc.
	# Tests that uses $gt_cc_compiler/$gt_ld_linker on a YottaDB build with ASAN (e.g. imptp.csh when
	# linking with SimpleAPI or SimpleThreadAPI wrapper) have been seen to have issues linking because
	# the .c files in the test system were compiled with gcc whereas libyottadb.so was compiled with clang.
	# Therefore use clang as the linker for the test system in this case.
	#
	# That said, we have seen that LD_LIBRARY_PATH env var, when set, affects the link on some systems
	# (noticed first on a RHEL 9 system). Therefore we unset this env var only for the link command.
	# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1815 for more details.
	setenv gt_ld_linker 'env LD_LIBRARY_PATH="" clang'
	# Note that we don't set clang to be the compiler in this case because gcc compiler flags and clang
	# compiler flags differ and "gt_cc_options_common" and "gt_cc_shl_options" env vars would be already
	# set to use gcc compiler flags. Hence the below is commented out.
	# ------------------
	# setenv gt_cc_compiler "clang"
	# ------------------
else
	setenv gtm_test_yottadb_compiler "GCC"
	# [source $gtm_tools/gtm_env.csh] would have already set gt_cc_compiler and gt_ld_linker to gcc
	# No changes needed in that case. But in case of multi-host tests, we would come in here with the
	# gt_ld_linker setting from the remote host and so we want to explicitly set the env var here to
	# override that. Note that "gt_cc_compiler" would already be set to "cc" which is "gcc" and so all
	# we need to do is to set gt_ld_linker to that to ensure it gets reset to the correct value in the
	# case where the local host has YottaDB built with gcc whereas the remote host has it built with clang.
	setenv gt_ld_linker "$gt_cc_compiler"
endif

