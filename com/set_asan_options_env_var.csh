#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Set ASAN_OPTIONS env var with various flags
#	detect_leaks=0           : To disable leak sanitizer checks as we know YottaDB has memory leaks and will address them separately.
#	abort_on_error=1         : Abort whenever a buffer overflow etc. is detected. This stops the process at first error.
#	disable_coredump=0       : To generate a core file when a buffer overflow etc. is detected. Easier to debug.
#	unmap_shadow_on_exit=1   : Needed to unmap the huge shadow at exit. Or else core files would be huge (Tera bytes).
#	verify_asan_link_order=0 : A few tests fail without this flag. It is not considered critical so we turn this flag off always.
#
# See following for full list of flags
#	https://github.com/google/sanitizers/wiki/AddressSanitizerFlags#run-time-flags
#	https://github.com/google/sanitizers/wiki/SanitizerCommonFlags
#
setenv ASAN_OPTIONS "detect_leaks=0:abort_on_error=1:disable_coredump=0:unmap_shadow_on_exit=1:verify_asan_link_order=0"

# Randomly enable stack use after return detection in ASAN. This is not enabled by default in GCC or in CLANG 14 or less.
# The below is a test of YDB@74eaf4ae. Without the changes in that commit, one would see a "%YDB-F-GTMASSERT2" in
# sr_port/mprof_funcs.c (stack_leak_check() function). See that commit message for more details.
# Do this enabling only a small fraction of the time (not 50%) as this setting causes a lot more memory to be used
# (since each stack frame creation during program execution will end up doing a malloc internally).
# We currently choose 25% (1 out of 4 chances).
set enable_detect_stack_use_after_return = `shuf -i 0-3 -n 1`	# 0, 1, 2, 3 are equally likely.
if (1 == $enable_detect_stack_use_after_return) then		# Enable only when it is 1 (which is 25% likely)
	setenv ASAN_OPTIONS "${ASAN_OPTIONS}:detect_stack_use_after_return=1"
else
	# Need to set explicitly to 0 as default option might be 1 (e.g. CLANG 15 and higher).
	setenv ASAN_OPTIONS "${ASAN_OPTIONS}:detect_stack_use_after_return=0"
endif

