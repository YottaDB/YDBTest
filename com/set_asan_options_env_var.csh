#!/usr/local/bin/tcsh -f
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
