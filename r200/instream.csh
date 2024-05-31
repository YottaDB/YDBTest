#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#---------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#---------------------------------------------------------------------------------------------------------------------------------------------------
# ydb996      [nars]    Test that LISTENING TCP sockets can be passed
# ydb998      [sam]     TSTART should not open the default global directory
# ydbpython32 [sam]     CTRL-C on Flask Application terminates properly
# ydb994      [nars]    Test various code issues identified by fuzz testing
# ydb1024     [nars]    Fix OPEN of a socket type file name to not assert fail in io_open_try.c
# ydb1026     [nars]    Test that ZWRITE to file output device with STREAM + NOWRAP does not split/break lines
# ydb1021     [nars]    Test that MUPIP SET JOURNAL is able to switch older format journal files (without a FILEEXISTS error)
# ydb1029     [nars]    Test an incorrect assert that used to exist in mdb_condition_handler() related to jobinterrupt
# ydb1030     [nars]    Test SRCBACKLOGSTATUS message in case of a passive source server has no misleading WARNING
# ydb1033     [estess]  Test $ZCMDLINE can be both NEW'd and SET
# ydb1037     [nars]    Test that %YDB-E-STACKCRIT secondary error does not happen with ZTRAP in direct mode
# ydb892      [nars]    Test that DSE INTEG -BLOCK=3 does not assert fail in an empty database
# ydb851      [nars]    Test that MUPIP commands accept either space or "=" after "-region"
# zmaxtptime  [nars]    Test that negative values of $ZMAXTPTIME are treated as 0 just like ydb_maxtptime
# ydb401      [berwyn]  Test YottaDB Direct Mode "RECALL" command
# ydb1047     [nars]    Test that MUPIP INTEG -STATS does not SIG-11 and MUPIP TRIGGER does not assert fail if ydb_statshare=1
# ydb1062     [nars]    Test that MUPIP TRIGGER -STDIN reports correct line numbers
# ydb88_01    [ern0]    Readline Support: Single session history
# ydb88_02    [ern0]    Readline Support: History saved by one session and loaded by another
# ydb88_03    [ern0]    Readline Support: Concurrent sessions combine histories
# ydb88_04    [ern0]    Readline Support: $HOME: override history location
# ydb88_05    [ern0]    Readline Support: $HOME: long directory name
# ydb88_06    [ern0]    Readline Support: $HOME: directory name with spaces
# ydb88_07    [ern0]    Readline Support: $HOME: fail on unwritable location
# ydb88_08    [ern0]    Readline Support: $HOME: LKE/DSE/MUPIP ERR_READLINELONGLINE test
# ydb88_09    [ern0]    Readline Support: Max entries: no limit (-5), 2, 0
# ydb88_10    [ern0]    Readline Support: History truncation upon save
# ydb88_11    [ern0]    Readline Support: Current session behavior with truncation (sliding numbers for rec/recall)
# ydb88_12    [ern0]    Readline Support: Duplicate sequential commands are not stored
# ydb88_13    [ern0]    Readline Support: Pressing ^C should cancel the command started typing
# ydb88_14    [ern0]    Readline Support: Handle ^C (SIGINT) received from outside
# ydb88_15    [ern0]    Readline Support: Tab in emacs and in vi mode actually issues tab
# ydb88_16    [ern0]    Readline Support: Process terminated by $ZTIMEOUT requires stty sane to regain sanity"
# ydb88_17    [ern0]    Readline Support: Validate that the history file does not grow beyond 1000 entries
# ydb88_18    [ern0]    Readline Support: Validate that the application name for $if blocks in INPUTRC is "YottaDB"
#---------------------------------------------------------------------------------------------------------------------------------------------------

echo "r200 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb996"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb998"
setenv subtest_list_non_replic "$subtest_list_non_replic ydbpython32"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb994"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1024"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1026"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1021"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1029"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1030"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1033"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1037"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb892"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb851"
setenv subtest_list_non_replic "$subtest_list_non_replic zmaxtptime"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb401"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1047"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb1062"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_01"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_02"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_03"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_04"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_05"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_06"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_07"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_08"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_09"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_10"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_11"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_12"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_13"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_14"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_15"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_16"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_17"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb88_18"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Python/Flask does not work well with ASAN. Disable ydbpython32.
# (We get the correct error: __asan::ReportDeadlySignal, but we don't want to see that)
source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	setenv subtest_exclude_list "$subtest_exclude_list ydbpython32"
endif

if ($?ydb_test_inside_docker) then
	# Test ydb1021 relies on a hardcoded prior version, which is not available in the docker system
	# Disable it if we are running inside docker
	if ( "0" != $ydb_test_inside_docker ) then
		setenv subtest_exclude_list "$subtest_exclude_list ydb1021"
	endif
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r200 test DONE."
