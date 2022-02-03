#!/usr/local/bin/tcsh -f
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
# pluginsonly		[bdw]		Test that --plugins-only installs various plugin combinations without errors
# ydb783 [sam]           Set $ZROUTINES to $ydb_dist/utf8/libyottadbutil.so if ydb_chset=UTF-8 and ydb_routines is not set
#
setenv subtest_list_common "sourceInstall diffDir ydb306 gtm9116 plugins pluginsonly ydb783"
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic"
setenv subtest_list_replic ""

setenv subtest_list "$subtest_list_common $subtest_list_non_replic $subtest_list_replic"

# EXCLUSIONS
setenv subtest_exclude_list ""

$gtm_tst/com/submit_subtest.csh
echo "sudo tests DONE."
