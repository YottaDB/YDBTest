#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "STRESS test starts..."
unset echo
unset verbose
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_replic	""
setenv subtest_list_replic	"$subtest_list_replic manyvars"
setenv subtest_list_replic	"$subtest_list_replic concurr_small"
setenv subtest_list_replic	"$subtest_list_replic concurr"
setenv subtest_list_replic	"$subtest_list_replic concurr_replwason"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif
# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list concurr_small concurr"
endif

# Enable white-box testing and trigger errors in the midst of commit. Do not do that very frequently as that might
# slow down GT.M update rate (due to frequent cache recoveries). We want to do this in the stress test to ensure that
# errors in the midst of commit are handled properly in all possible configurations (the stress test tests a wide
# variety of codepaths by running as many processes concurrently as are allowed e.g. mupip load, backup, reorg etc.).
# Note that white-box testing is active within GT.M only in case of a dbg image. Therefore in case of a pro image,
# this white-box testing block does not change the code coverage of the test in any way.
if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# set environment variables to enable white-box test of cache recovery
	# Keep the error frequency to at least 2000. A low error frequency causes updates to do cache recovery quite often thereby
	# flooding the syslog with WCBLOCKED, DBCRERR and other cache recovery related messages. Because the crit is held by the process
	# writing to the syslog, frequent syslogging causes a significant delay, causing timeouts on stress tests.
	# <syslog_flooding_slowsdown>
	source $gtm_tst/com/wbox_test_prepare.csh "CACHE_RECOVER" 100000 2000 settings.csh
	# Randomly set "gtm_fullblockwrites" to 1
	# This will make sure we test the full-block-writes code out very well.
	set fullblock_rand = `date | $tst_awk '{srand () ; print int(2 * rand ())}'`
	setenv gtm_fullblockwrites $fullblock_rand
	# log it in settings.csh file
	echo "setenv gtm_fullblockwrites $gtm_fullblockwrites" >> settings.csh
endif

set hostn = $HOST:r:r:r

# Adding sync_io to tst_jnl_str can have a significant effect on run times for the stree/concurr test.  For
# this reason the sync_io randomization is only done as part of the stress test and not as a general
# change to the test framework.
setenv is_syncio ""
# The following boxes are known to fail with this setting so don't do it <stress_sync_io_slowdown>
if ($hostn !~ {atlst2000,pfloyd,atlhxit1,charybdis,lespaul}) then
	@ rand = `$gtm_exe/mumps -run rand 2`
	if (1 == $rand) then
		if ("linux" == $gtm_test_osname) then
			set tmp_ver = `uname -r | sed 's/\./ /g'`
			# Linux versions before 2.6 have restrictions on DIRECTIO which are not supported in GT.M
			if ((2 < $tmp_ver[1]) || ((2 == $tmp_ver[1]) && (6 <= $tmp_ver[2]))) then
			    setenv is_syncio ",sync_io"
			endif
		else
			setenv is_syncio ",sync_io"
		endif
	endif
endif

$gtm_tst/com/submit_subtest.csh
echo "STRESS test done."
