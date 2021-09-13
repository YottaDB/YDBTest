#################################################################
#								#
# Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	#
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

# Rust is known to segfault on 32-bit platforms when compiling in release mode
# (https://github.com/rust-lang/rust/issues/72894)
if (0 == $rand || "armv6l" == `uname -m`) then
	set rust_target_dir = "debug"
else
	set cargo_build = "$cargo_build --release"
	set rust_target_dir = "release"
endif

# If `bindgen` is already installed, use that instead of compiling from source.
# This can save almost half an hour when compiling on Raspberry PIs.
if (`where bindgen` != "") then
	set cargo_build = "$cargo_build --no-default-features"
endif

# Set link arguments for libyottadb.so
setenv RUSTFLAGS "-C link-args=$ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb"
# Give a backtrace if the wrapper panics
setenv RUST_BACKTRACE 1
