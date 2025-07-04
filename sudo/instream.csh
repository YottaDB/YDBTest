#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
######################################################################
# sudo_start.csh                                                     #
# all subtests in this test are automated, but won't run as part of  #
# the daily/weekly cycle. The tests here will be started manually in #
# a controlled fashion, e.g. during the regression testing phase for #
# a major release. All of these tests require 'sudo' to run.         #
######################################################################
#
# sourceInstall				[mmr]		Test that ydbinstall.sh when sourced will give an error then exit
# diffDir				[mmr]		Test that ydbinstall.sh when called from anothre directory will still install properly
# ydb306				[kz]		Test that --zlib and --utf8 will run together with ydbinstall.sh
# gtm9116				[bdw]		Test that ydbinstall.sh installs libyottadb.so with 755 permissions irrespective of what umask is set to
# plugins				[bdw]		Test that ydbinstall.sh installs various plugin combinations without errors
# ydb783				[sam]		Set $ZROUTINES to $ydb_dist/utf8/libyottadbutil.so if ydb_chset=UTF-8 and ydb_routines is not set
# gtm7759				[estess]	Test that expected log message do and don't show up depending on restrict.txt setting
# ydb894				[jv]		Test that --nopkg-config will not create or modify yottadb.pc with ydbinstall/ydbinstall.sh
# ydb880				[jv]		Test ydbinstall/ydbinstall.sh --linkexec, --linkenv, --copyexec, and --copyenv options
# ydb910				[jv]		Test that --from-source builds and installs YottaDB without any errors with ydbinstall/ydbinstall.sh
# ydb924				[jv]		Test that ydbinstall/ydbinstall.sh terminates if not run as root, unless --dry-run is specified
# gtm8517				[estess]	Test that install permissions and checksum files are created by install and are non-zero
# olderversion				[sam]		Test to see if ydbinstall can successfully install older versions
# gtm9324				[estess]	Test ZSTEP restored/continues after $ZINTERRUPT or $ZTIMEOUT, also restrict.txt treats ZBREAK like ZSTEP
# gtm9408				[nars]		Test that HANG command does not hang indefinitely if system date is reset back in time
# configure_rmfile-gtmde201825		[pooh]		Test that the configure script removes semstat2, ftok, and geteuid in GT.M V7.0-002 and later
# support				[david] 	Test that ydb_support.sh gathers the correct support information without issues
# erofs-ydb1103				[nars]		Test that database file open does not issue DBFILERR error (EROFS) in read-only file system
# env_for_huge_and_shm-gtmf135288	[ern0]		Test huge pages support: setting gtm_pinshm and gtm_hugetlb_shm env variables to true
# gtmsecshrsrvf-ydb_tmp-ydb1112		[nars]		Test that ydb_tmp env var mismatch between multiple clients results in GTMSECSHRSRVF errors
# gtmsecshrsrvf-ydb_env_set-ydb1112	[nars]		Test ydb_env_set sets ydb_tmp env var appropriately and avoids GTMSECSHRSRVF errors
# shmhugetlb_syslog-gtmf221672		[jon]		Test that additional context is included in SHMHUGETLB syslog messages
# tmpyottadbperms-ydb1125		[jon]		Test that /tmp/yottadb and /tmp/yottadb/<rel> have correct permissions
# gtmsecshr_racecondition-gtmde506361	[jon]		Test GTMSECSHR appropriately handles a rare condition when two processes attempt to start a GTMSECSHR process simultaneously

setenv subtest_list_common ""
setenv subtest_list_common "$subtest_list_common sourceInstall"
setenv subtest_list_common "$subtest_list_common diffDir"
setenv subtest_list_common "$subtest_list_common ydb306"
setenv subtest_list_common "$subtest_list_common gtm9116"
setenv subtest_list_common "$subtest_list_common plugins"
setenv subtest_list_common "$subtest_list_common ydb783"
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7759"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb894"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb880"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb910"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb924"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8517"
setenv subtest_list_non_replic "$subtest_list_non_replic olderversion"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm9324"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm9408"
setenv subtest_list_non_replic "$subtest_list_non_replic configure_rmfile-gtmde201825"
setenv subtest_list_non_replic "$subtest_list_non_replic support"
setenv subtest_list_non_replic "$subtest_list_non_replic erofs-ydb1103"
setenv subtest_list_non_replic "$subtest_list_non_replic env_for_huge_and_shm-gtmf135288"
setenv subtest_list_non_replic "$subtest_list_non_replic gtmsecshrsrvf-ydb_env_set-ydb1112"
setenv subtest_list_non_replic "$subtest_list_non_replic gtmsecshrsrvf-ydb_tmp-ydb1112"
setenv subtest_list_non_replic "$subtest_list_non_replic shmhugetlb_syslog-gtmf221672"
setenv subtest_list_non_replic "$subtest_list_non_replic tmpyottadbperms-ydb1125"
setenv subtest_list_non_replic "$subtest_list_non_replic gtmsecshr_racecondition-gtmde506361"
setenv subtest_list_replic ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# EXCLUSIONS
setenv subtest_exclude_list ""

# The plugins test is disabled on ARMVXL due to periodic network related failures on ARMV6L. Attempting to add
# retries to the test did not address these failures so we've disabled the test.
if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	setenv subtest_exclude_list "$subtest_exclude_list plugins"
else if ("rhel" == $gtm_test_linux_distrib) then
	if ("7.9" == $gtm_test_linux_version) then
		# https://gitlab.com/YottaDB/Tools/YDBCMake/-/merge_requests/21 made the following change.
		#	Always set locale to C.UTF-8. It's available in all modern Linux distros.
		# But C.UTF-8 is not available on RHEL 7. And the "plugins" subtest uses ydbinstall to install
		# the "encplugin", "aim" and "posix" plugins, all of which use the YDBCMake framework and so will
		# not work on RHEL 7. Therefore disable this subtest on RHEL 7.
		#
		setenv subtest_exclude_list "$subtest_exclude_list plugins"
		# olderversion disabled since no binaries for RHEL 7 (it's not supported) since r1.36
		setenv subtest_exclude_list "$subtest_exclude_list olderversion configure_rmfile-gtmde201825"
	endif
	if ($gtm_test_rhel9_plus) then
		# RHEL 9 does not have a r1.38 tarball (which the below subtest relies on) so skip in that case
		setenv subtest_exclude_list "$subtest_exclude_list configure_rmfile-gtmde201825"
	endif
else if (("ubuntu" == $gtm_test_linux_distrib) && ("20.04" == $gtm_test_linux_version)) then
	# olderversion disabled since no binaries for Ubuntu 20.04 (not all versions supported)
	setenv subtest_exclude_list "$subtest_exclude_list olderversion configure_rmfile-gtmde201825"
else if ("suse" == $gtm_test_linux_distrib) then
	# olderversion disabled since no binaries for Opensuse Tumbleweed (not supported)
	if ("opensuse-tumbleweed" == $gtm_test_linux_suse_distro) then
		setenv subtest_exclude_list "$subtest_exclude_list olderversion configure_rmfile-gtmde201825"
	endif
endif

if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out ydb910 subtest on 32-bit ARM since it requires building YottaDB from source which will take a long time.
	# filter out gtm9324 on 32-bit ARM due to https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1773#note_1696945962
	setenv subtest_exclude_list "$subtest_exclude_list ydb910 gtm9324"
endif

# Disable gtm9408 subtest on
# 1) AARCH64/ARMV6L as it is very sensitive to test runtime (measures elapsed time of HANG command)
#    and is likely to fail on those slow systems.
# 2) RHEL/CentOS/SUSE as timesyncd does not seem to reset the system clock automatically (after the test resets the
#    system date back in time. Not clear why and is not considered worth it considering Debian and Ubuntu run the test fine.
if (("HOST_LINUX_X86_64" != $gtm_test_os_machtype)			\
		|| (("ubuntu" != $gtm_test_linux_distrib) && ("debian" != $gtm_test_linux_distrib))) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9408"
endif

# Disable Huge page test on ARM machines due to lack of memory
if (("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
	setenv subtest_exclude_list "$subtest_exclude_list env_for_huge_and_shm-gtmf135288 shmhugetlb_syslog-gtmf221672"
endif

# Disable Huge page test on Docker, as it requires changing /proc/sys which is not normally writable
# Disable erofs-ydb1103 on Docker, as it requires mounting permissions from host
if ($?ydb_test_inside_docker) then
	if (1 == $ydb_test_inside_docker) setenv subtest_exclude_list "$subtest_exclude_list env_for_huge_and_shm-gtmf135288 erofs-ydb1103"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	# We intentionally produce cores in the support test; with ASAN enabled,
	# the cores become very large files that fill up the disk
	# Therefore, disable cores if ASAN is enabled.
	setenv subtest_exclude_list "$subtest_exclude_list support"
endif

if ("ENCRYPT" == $test_encryption) then
	# The below subtest uses sudo and su to run as a different userid and exercises the DBPRIVERR error.
	# But in order to get this error, one needs to pass encryption env vars gtm_passwd/gtmcrypt_config etc.
	# and that is not trivial. It is not worth trying to make it work with -encrypt so just disable it.
	setenv subtest_exclude_list "$subtest_exclude_list gtm7759"
endif

if ($?ydb_test_inside_docker) then
	if ( "0" != $ydb_test_inside_docker ) then
		# Disable the following subtest until YDB commit 31205c980c04a21f63b201a740e6fd5065b5c987 is released, since
		# this commit contains the changes under test. Until then, this test is guaranteed to fail when run in Docker
		# due to the Docker test container's reliance on published releases. Since commit 31205c98 is not yet released
		# any release pulled by the Docker container for testing will omit the relevant changes, causing the test to reliably fail.
		setenv subtest_exclude_list "$subtest_exclude_list tmpyottadbperms-ydb1125"
		# Disable the following subtest due to https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2206#note_2274448098
		setenv subtest_exclude_list "$subtest_exclude_list gtmsecshrsrvf-ydb_tmp-ydb1112"
		# Disable the following subtest due to similar reasons as the above subtest
		setenv subtest_exclude_list "$subtest_exclude_list gtmsecshrsrvf-ydb_env_set-ydb1112"
	endif
endif

# Save a copy of the current system yottadb.pc before it gets modified by the various ydbinstall.sh invocations done in the
# various subtests of the sudo test. This way we can restore the system copy at the end of the test and avoid the system
# yottadb.pc pointing to a non-existent YottaDB installation somewhere under the test output directory (that gets deleted
# at the end of the test run).
if (-e /usr/share/pkgconfig/yottadb.pc) then
	sudo cp -p /usr/share/pkgconfig/yottadb.pc .
	set ydbpcexists=1
else
	set ydbpcexists=0
endif

$gtm_tst/com/submit_subtest.csh

# Restore the copy of the current system yottadb.pc
if (1 == $ydbpcexists) then
	sudo cp -p yottadb.pc /usr/share/pkgconfig/yottadb.pc
	sudo rm yottadb.pc
endif

echo "sudo tests DONE."
