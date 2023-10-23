#################################################################
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ($gtm_test_libyottadb_asan_enabled) then
	if ($?gt_ld_options_common) then
		# gt_ld_options_common env var is defined. Add -fsanitize=address to it.
		# Add address sanitizer related flags to the former (if YottaDB build being tested was linked with it).
		# This way any "$gt_ld_options_common" usages in the tests automatically linked with libasan.
		# Not doing so would cause tests that use "gt_ld_options_common" to fail as follows.
		#	ASan runtime does not come first in initial library list; you should either link runtime to your application or manually preload it with LD_PRELOAD
		setenv gt_ld_options_common "$gt_ld_options_common -fsanitize=address"
	endif
	source $gtm_tst/com/set_asan_options_env_var.csh
	# If ASAN checks are happening, it is more likely for it to detect memory issues if YottaDB uses the system malloc/free.
	# Therefore, disable the YottaDB memory manager by setting gtmdbglvl to the below specific value. Do this randomly
	# so we also test ASAN with the YottaDB memory manager, not just with the system memory manager. Note that this env
	# var is modified in various tests to specific values (using "setenv gtmdbglvl" and "unsetenv gtmdbglvl"). Those places
	# can be enhanced to set gtmdbglvl to this value. For example,
	# - A "unsetenv gtmdbglvl" can be replaced by a "setenv gtmdbglvl 0x80000000"
	# - A "setenv gtmdbglvl 0x80" can be replaced by a "setenv gtmdbglvl 0x80000080"
	# The places that might benefit from this is suspected to be a very small fraction of the test system and hence it is
	# not considered worth the effort right now. That is left as a future activity if/when it becomes useful enough.
	set enable_system_malloc_free = `shuf -i 0-1 -n 1`
	if ($enable_system_malloc_free) then
		source $gtm_tst/com/set_gtmdbglvl_to_use_system_malloc_free.csh
	endif
endif

