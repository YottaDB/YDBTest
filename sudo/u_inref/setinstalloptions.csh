#################################################################
#								#
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Script that is invoked by various subtest scripts of the "sudo" test so they can use the following variables.
#	$installoptions
#	$sudostr
#
# Never invoked as a base script. Always sourced from a caller tcsh script (e.g. sourceInstall.csh, diffDir.csh etc.).
set linux_distrib = `awk -F= '$1 == "ID" {print $2}' /etc/os-release | sed 's/"//g'`
set osver = `awk -F= '$1 == "VERSION_ID" {print $2}' /etc/os-release | sed 's/"//g'`
set installoptions = ""
if (("$linux_distrib" == "arch")							\
		|| (("$linux_distrib" == "debian") && (`uname -m` == "aarch64"))	\
		|| (("$linux_distrib" == "raspbian") && (`uname -m` == "armv6l"))) then
	set installoptions = "$installoptions --force-install"
endif

# Need to preserve ydb_icu_version env var across the sudo call. Or else yottadb invocations inside the sudo won't work correctly
# on SLED 15 systems (see YDBTest@154981e3 and/or YDB@38cd9956 for more details).
set sudostr = "sudo --preserve-env=ydb_icu_version"
source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# Check if YottaDB is built with ASAN.
if ($gtm_test_libyottadb_asan_enabled) then
	# Disable memory leak detection inside sudo as the leak sanitizer (LSAN) currently detects leaks in a PRO build
	# and causes a build failure. We will address memory leaks at a later time (YDB#816) as they are not as critical as buffer
	# overflows etc. ASAN_OPTIONS env var already has the needed flags for this. So just preserve this env across the sudo.
	set sudostr = "$sudostr --preserve-env=ASAN_OPTIONS"
endif
