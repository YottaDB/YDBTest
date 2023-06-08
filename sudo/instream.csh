#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
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
# sourceInstall		[mmr]		Test that ydbinstall.sh when sourced will give an error then exit
# diffDir		[mmr]		Test that ydbinstall.sh when called from anothre directory will still install properly
# ydb306		[kz]		Test that --zlib and --utf8 will run together with ydbinstall.sh
# gtm9116		[bdw]		Test that ydbinstall.sh installs libyottadb.so with 755 permissions irrespective of what umask is set to
# plugins		[bdw]		Test that ydbinstall.sh installs various plugin combinations without errors
# ydb783		[sam]		Set $ZROUTINES to $ydb_dist/utf8/libyottadbutil.so if ydb_chset=UTF-8 and ydb_routines is not set
# gtm7759	 	[estess]	Test that expected log message do and don't show up depending on restrict.txt setting
# ydb894		[jv]		Test that --nopkg-config will not create or modify yottadb.pc with ydbinstall/ydbinstall.sh
# ydb880		[jv]		Test ydbinstall/ydbinstall.sh --linkexec, --linkenv, --copyexec, and --copyenv options
# ydb910		[jv]		Test that --from-source builds and installs YottaDB without any errors with ydbinstall/ydbinstall.sh
# ydb924		[jv]		Test that ydbinstall/ydbinstall.sh terminates if not run as root, unless --dry-run is specified
# gtm8517		[estess]	Test that install permissions and checksum files are created by install and are non-zero
#
setenv subtest_list_common "sourceInstall diffDir ydb306 gtm9116 plugins ydb783"
setenv subtest_list_non_replic "gtm7759 ydb894 ydb880 ydb910 ydb924 gtm8517"
setenv subtest_list_non_replic "$subtest_list_non_replic"
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
else if (("rhel" == $gtm_test_linux_distrib) && ("7.9" == $gtm_test_linux_version)) then
	# https://gitlab.com/YottaDB/Tools/YDBCMake/-/merge_requests/21 made the following change.
	#	Always set locale to C.UTF-8. It's available in all modern Linux distros.
	# But C.UTF-8 is not available on RHEL 7. And the "plugins" subtest uses ydbinstall to install
	# the "encplugin", "aim" and "posix" plugins, all of which use the YDBCMake framework and so will
	# not work on RHEL 7. Therefore disable this subtest on RHEL 7.
	setenv subtest_exclude_list "$subtest_exclude_list plugins"
endif

if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out below subtest on 32-bit ARM since it requires building YottaDB from source which will take a long time
	setenv subtest_exclude_list "$subtest_exclude_list ydb910"
endif

# Save a copy of the current system yottadb.pc before it gets modified by the various ydbinstall.sh invocations done in the
# various subtests of the sudo test. This way we can restore the system copy at the end of the test and avoid the system
# yottadb.pc pointing to a non-existent YottaDB installation somewhere under the test output directory (that gets deleted
# at the end of the test run).
if (-e /usr/share/pkgconfig/yottadb.pc) then
	sudo cp /usr/share/pkgconfig/yottadb.pc .
	set ydbpcexists=1
else
	set ydbpcexists=0
endif

$gtm_tst/com/submit_subtest.csh

# Restore the copy of the current system yottadb.pc
if (1 == $ydbpcexists) then
	sudo cp yottadb.pc /usr/share/pkgconfig/yottadb.pc
	sudo rm yottadb.pc
endif

echo "sudo tests DONE."
