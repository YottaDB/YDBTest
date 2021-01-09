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

# The only dependencies YDBRust has are build dependencies on bindgen and pkg-config.
# These execute basically instantaneously, so there is no need to optimize them.
#
# This used to be set in the Cargo.toml of YDBRust as
# `profile.release.package."*"`.  Unfortunately, that wasn't supported before
# Rust 1.41. In 1.34, it was just ignored, but in 1.40 it was changed to a hard
# error because it was implemented on nightly behind a feature gate. Set an
# environment variable instead, which degrades gracefully even if it isn't
# supported.
#
# TODO: Once the minimum rust version for YDBRust is increased to 1.41, this
# variable can be deleted and the override moved to YDBRust directly (i.e, add
# back the `[profile.release.package."*"]` section removed in
# https://gitlab.com/YottaDB/Lang/YDBRust/-/merge_requests/110).
setenv CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_OPT_LEVEL 0
