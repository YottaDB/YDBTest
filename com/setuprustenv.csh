#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This script is meant to be sourced by Rust tests to build the YDBRust wrapper
# before building/running the specific Rust test.

set tstpath = `pwd`
setenv PKG_CONFIG_PATH $ydb_dist

# Retrieve YDBRust package from the repository using git
# Test both release and debug mode randomly
# Use release more often than debug since it will make the tests much faster.
set cargo_build = "cargo build"
set rand = `$gtm_exe/mumps -run rand 4`

if (0 == $rand) then
	set rust_target_dir = "debug"
else
	set cargo_build = "$cargo_build --release"
	set rust_target_dir = "release"
endif

# Set link arguments for libyottadb.so
setenv RUSTFLAGS "-C link-args=$ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb"
# Give a backtrace if the wrapper panics
setenv RUST_BACKTRACE 1
