#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
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
# Subtests with "mr" suffix in their name correspond to merge requests whereas no "mr" implies issues (the most common case).
# So "ydb346mr" is a test for code changes in !346 (merge request 346) (note: merge requests are indicated by !) whereas
#    "ydb346"   is a test for code changes in #346 (issue 346)
#----------------------------------------------------------------------------------------------------------------------------------------------------------
# readonly         [nars]  Test update on database with READ_ONLY flag through multiple global directories
# ydb275socketpass [nars]  Test that LISTENING sockets can be passed through JOB or WRITE /PASS and WRITE /ACCEPT
# ydb280socketwait [nars]  Test that WRITE /WAIT on a SOCKET device with no sockets does not spin loop
# ydb282srcsrvrerr [nars]  Test that source server clears backlog and does not terminate with FILEDELFAIL or RENAMEFAIL errors
# jnlunxpcterr     [nars]  Test that MUPIP JOURNAL -EXTRACT does not issue JNLUNXPCTERR error in the face of concurrent udpates
# ydb293           [vinay] Tests the update process operates correctly with triggers and SET $ZGBLDIR
# ydb297           [vinay] Demonstrates LOCK commands work correctly when there are more than 31 subscripts that hash to the same value
# ydb312_gtm8182a  [Jake]  Test that when Instance Freeze is disabled a process attaches a region to an instance at the first update to that region.
# ydb312_gtm8182b  [jake]  Test $zpeek of journal pool to ensure there is no longer a memory leak issue with jnlpool_init()
# ydb312_gtm8182c  [jake]  Test that an error in DB freezes only the instance corresponding to that DB and not an unrelated instance
# ydb312_gtm8182d  [jake]  Test that opening the jnlpool as part of an update works fine after unsuccessfully opening the jnlpool as part of a read
# ydb312_gtm8182e  [jake]  Test a fix for an incorrect GTMASSERT2 error when [gtm/ydb]_repl_instance env vars are unset and an instance has no repl file mapping
# ydb312_gtm8182f  [jake]  Test a fix for an incorrectly issued REPLINSTMISMTCH error in a LOCK command with extended references in a process that accesses multiple instances
# ydb312_gtm8182g  [jake]  Test that updating DB1, in GLD1, and DB2, in GLD2, will only attach to the journal pool once when DB1/2 are both within GLD3 ( associate with a replicating source server)
# ydb315           [jake]  Test that the ZCOMPILE operation will not display warning if $ZCOMPILE contains "-nowarnings"
# ydb324           [nars]  Test that Error inside indirection usage in direct mode using $ETRAP (not $ZTRAP) does not terminate process
# ydb321           [nars]  Test that journal records fed to external filters include timestamps
# ydb341           [nars]  Test that epoch_interval setting is honored even if an idle epoch is written
# ydb343           [nars]  Test that use of a local variable after a Ctrl-C'ed ZWRITE in direct mode does not issue assert failure
# ydb346mr         [nars]  Test that WRITE ?1 in direct mode after setting LENGTH of $PRINCIPAL to 0 does not assert fail
# ydb350           [nars]  Test that terminal has ECHO characteristics after READ or WRITE or direct-mode-read commands
# ydb352           [nars]  Test that ydb_ci() call with an error after a ydb_set_s() of a spanning node does not GTMASSERT2
# ydb353           [nars]  Test that VIEW "NOISOLATION" optimization affects atomicity of $INCREMENT inside TSTART/TCOMMIT
# ydb348           [nars]  Test that OPEN of a SOCKET that was closed after a TPTIMEOUT error (during a SOCKET READ) does not GTMASSERT
# ydb358           [nars]  Test that AIO writes in simpleAPI parent and child work fine (no DBIOERR error)
# ydb359           [nars]  Test that ZSTEP actions continue to work after a MUPIP INTRPT if $ZINTERRUPT is appropriately set
# ydb356           [nars]  Test that an extended reference that gets a NETDBOPNERR error when $ydb_gbldir is not set does not SIG-11
# ydb360           [nars]  Test that $ZEDITOR reflects exit status of the last ZEDIT invocation
# ydb357           [nars]  Test that SIGQUIT (kill -3) sent to a mumps process during ZSYSTEM/ZEDIT is handled little later but not lost
# ydb346           [nars]  Test that MUPIP INTEG, DSE DUMP and MUMPS do not infinite loop in case of INVSPECREC error
# ydb95            [nars]  Test that MUPIP LOAD on an empty ZWR file reports 0 loaded records and no errors
# ydb361           [nars]  Test that Receiver Server does not issue REPLINSTNOHIST error on restart after first A->P connection
# ydb333           [nars]  Test that $VIEW("PROBECRIT") has CPT statistic with nanosecond (not microsecond) resolution
# ydb364           [nars]  Test that Source Server shutdown command says it did not delete jnlpool ipcs even if the instance is frozen
# ydb329           [nars]  Test that compiling M program in UTF-8 mode issues an appropriate INVDLRCVAL error without a GTMASSERT2
# ydb344	   [quinn] Test that after calling ydb_zwr2str_s(), no subsequent SimpleAPI calls get a SIMPLAPINEST error.
# ydb258	   [quinn] Tests that literal indirection does not give a YDB-F-KILLBYSIGSINFO01 error.
# ydb374	   [quinn] Test that compiling with the use of the embed_source flag does not include $C(13) at the end of the source line.
# ydb372	   [quinn] Test that using indirection in a setleft works even if a preceeding setleft has an invalid ISV usage, and does not give a GTMASSERT2 error.
# ydb363	   [quinn] Test that YottaDB correctly issues NUMOFLOW errors for literal expressions whic contain large numeric values stored as strings.
# ydb371	   [quinn] Test that $SELECT stops evaluating tvexprs or exprs once a true tvexpr is seen even in case later tvexprs or exprs contain a NUMOFLOW or INVDLRCVAL error.
# ydb349	   [nars]  Test that MUPIP REORG on database file with non-zero RESERVED_BYTES does not cause integrity errors
# ydb197	   [quinn] Test that ydb_env_set changes ydb_routines/gtmroutines/ydb_gbldir/gtmgbldir values appropriately whether preset or unset.
# ydb233	   [quinn] Test of mupip set -reorg_sleep_nsec
# ydb309	   [quinn] Test that invoking ydb_env_set does not clear the value of gtm_prompt if ydb_prompt is undefined.
# ydb383           [nars]  Test that ydb_tp_s() returns negative error code for GBLOFLOW error
# ydb362a	   [quinn] Test that connecting to a Source instance with a version prior to V60000 gives a YDB-E-UNIMPLOP and YDB-I-TEXT error.
# ydb362b	   [quinn] Test that connecting to a Receiver instance with a version prior to V60000 gives a YDB-E-UNIMPLOP and YDB-I-TEXT error.
# ydb113	   [quinn] Test that $$getncol^%LCLCOL returns expected values when ydb_lct_stdnull env var is set to various values.
# ydb114	   [quinn] Test that a new version does not change whatever settings are set in a global db set in a previous version.
# ydb191	   [quinn] Test that remote file name specifications in the client side GLD use the GT.CM GNP server as appropriate.
# ydb345	   [quinn] Tests that opening a PIPE device issues an error if STDERR is specified and points to an already open device.
# ydb369	   [quinn] Test that environmental variables can be set and unset using the VIEW "SETENV" and VIEW "UNSETENV" commands in mumps.
# ydb313	   [quinn] Test that MUPIP FTOK -JNLPOOL and MUPIP FTOK -RECVPOOL operate on the specified instance file and ignore ydb_repl_instance/gtm_repl_instance env var.
# ydb96		   [quinn] Test that executed DSE commands appear as AIMG records after extracting from a journal.
# ydb272	   [quinn] Test that the environment variable ydb_poollimit is honored by MUMPS and DSE.
# ydb230	   [quinn] Tests that using -1 as the optional parameter for $zsearch() returns the first file match instead of a ZSRCHSTRMCT error.
# ydb365	   [quinn] Test various MUPIP SET JOURNAL scenarios when BEFORE or NOBEFORE is not specified.
# ydb392	   [quinn] Test that ydb_linktmpdir/gtm_linktmpdir env var default to ydb_tmp/gtm_tmp before defaulting to /tmp
# ydb394	   [quinn] Test that when using a non-existent local variable, ydb_subscript_next_s()/ydb_subscript_previous_s() returns an empty string
# ydb401	   [quinn] Test that a call-in successfully invokes an external call that uses Simple API
# ydb402	   [quinn] Test that gtm_init(), gtm_ci(), and gtm_cip() can be successfully called to access M code
# ydb397	   [quinn] Test that SimpleAPI issues ZGBLDIRACC if ydb_app_ensures_isolation is set to a non-null value but global directory does not exist
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r124 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic readonly ydb275socketpass ydb280socketwait jnlunxpcterr ydb297 ydb315"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb324 ydb341 ydb343 ydb346mr ydb350 ydb352 ydb353 ydb348 ydb358 ydb359"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb356 ydb360 ydb357 ydb346 ydb95 ydb333 ydb329 ydb344 ydb258 ydb374"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb372 ydb363 ydb371 ydb349 ydb197 ydb233 ydb309 ydb383 ydb113 ydb114"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb191 ydb345 ydb369 ydb96 ydb272 ydb230 ydb365 ydb392 ydb394 ydb401"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb402 ydb397"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic ydb282srcsrvrerr ydb293 ydb312_gtm8182a ydb312_gtm8182b  ydb312_gtm8182c"
setenv subtest_list_replic     "$subtest_list_replic ydb312_gtm8182d ydb312_gtm8182e ydb312_gtm8182f ydb312_gtm8182g ydb321"
setenv subtest_list_replic     "$subtest_list_replic ydb361 ydb364 ydb362a ydb362b ydb313"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list ydb282srcsrvrerr"
endif

# filter out replication tests that use pre-V60000 versions because these versions do not have dbg builds.
if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list ydb362a ydb362b"
endif

if ($?ydb_test_exclude_V5_tests) then
	# If we are excluding subtests with a V5 prior version dependency, exclude ydb362a/b
	if ($ydb_test_exclude_V5_tests) then
		setenv subtest_exclude_list "$subtest_exclude_list ydb362a ydb362b"
	endif
endif

if ($?ydb_test_exclude_ydb362b) then
	if ($ydb_test_exclude_ydb362b) then
		# An environment variable is defined to indicate the below subtest needs to be disabled on this host
		setenv subtest_exclude_list "$subtest_exclude_list ydb362b"
	endif
endif

source $gtm_tst/com/set_gtm_machtype.csh	# to setenv "gtm_test_linux_distrib"
if (("HOST_LINUX_X86_64" == $gtm_test_os_machtype)			\
		&& (("arch" == $gtm_test_linux_distrib)			\
			|| ("ubuntu" == $gtm_test_linux_distrib)	\
			|| ("centos" == $gtm_test_linux_distrib)	\
			|| ("debian" == $gtm_test_linux_distrib))) then
	# The "jnlunxpcterr" subtest has seen to frequently cause a CPU soft lockup.
	# The actual error message in syslog is "watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [mupip:19422]"
	# For reasons not yet clear, this happens currently only on our Ubuntu/Arch/Debian x86_64 linux boxes,
	# never on RHEL x86_64 or any of the ARM boxes (even if they run Ubuntu/Arch/Debian).
	# So disable this subtest on those affected platforms.
	# Update to above note: This test started hanging on a CentOS 8 box too with the following message in syslog.
	#	"kernel: list_del corruption. next->prev should be ffff8a6ec1e091e0, but was dead000000000200"
	# Hence the decision to disable on `centos` too in the above `if` check.
	setenv subtest_exclude_list "$subtest_exclude_list jnlunxpcterr"
endif

if ("armv6l" == `uname -m`) then
	# The ydb333 test requires nanosecond-resolution clock. On ARMV6L we have found the clock to be microsecond-resolution,
	# i.e. the CPT values always are a multiple of 1000 or in rare cases end in 999 but never any other value between 1 and 998.
	# So disable this subtest on the ARMV6L.
	setenv subtest_exclude_list "$subtest_exclude_list ydb333"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	# Disable ydb358 subtest if YottaDB is built ASAN.
	setenv subtest_exclude_list "$subtest_exclude_list ydb358"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r124 test DONE."
