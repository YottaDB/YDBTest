#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r124 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic readonly ydb275socketpass ydb280socketwait jnlunxpcterr ydb297 ydb315"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb324 ydb341 ydb343 ydb346mr ydb350 ydb352 ydb353 ydb348 ydb358 ydb359"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb356 ydb360 ydb357 ydb346 ydb95 ydb333"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic ydb282srcsrvrerr ydb293 ydb312_gtm8182a ydb312_gtm8182b  ydb312_gtm8182c"
setenv subtest_list_replic     "$subtest_list_replic ydb312_gtm8182d ydb312_gtm8182e ydb312_gtm8182f ydb312_gtm8182g ydb321"
setenv subtest_list_replic     "$subtest_list_replic ydb361 ydb364"

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

if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out below test on 32-bit ARM since it relies on hash collisions which happen only on Linux x86_64 currently
	setenv subtest_exclude_list "$subtest_exclude_list ydb297"
endif

source $gtm_tst/com/set_gtm_machtype.csh	# to setenv "gtm_test_linux_distrib"
if (("arch" == $gtm_test_linux_distrib) || ("ubuntu" == $gtm_test_linux_distrib)) then
	# The "jnlunxpcterr" subtest has seen to frequently cause a CPU soft lockup.
	# The actual error message in syslog is "watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [mupip:19422]"
	# For reasons not yet clear, this happens currently only on our Ubuntu and Arch Linux boxes, never on RHEL or ARM boxes.
	# So disable this subtest on those affected platforms.
	setenv subtest_exclude_list "$subtest_exclude_list jnlunxpcterr"
endif

if ($gtm_platform_size != 64) then
	# Disable ydb358 subtest on 32-bit platforms as it requires ASYNCIO which is not enabled there
	setenv subtest_exclude_list "$subtest_exclude_list ydb358"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r124 test DONE."
