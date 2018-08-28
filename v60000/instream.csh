#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# gtm7227			[estess]       	Verify correct operation of SET $PIECE/$EXTRACT with large indexes
# C9B12001861			[base]		Verify that DSE and LKE bypasses MUPIP hang cause C9B12-001861
# gtm7283			[rog]		Verify the compiler gives an error for an extra decimal in a numeric literal
# gtm7312			[maimoneb]	Verify gtmsecshr wrapper cannot be fooled by a symbolic link
# less_log			[zouc]		Let the source server adpatively adjust logging frequency when the receiver server
#						is down
# gtm6686			[sopini]	Verify that under-construction util_out* buffers are protected
# gtm7277			[estess]	Boolean expression side-effect testing
# gtm7332			[estess]	Exponent test - make sure exponent results are properly tagged
# gtm6692			[base]		Verify that GT.M bypasses if process count is greater than twenty times the number
#						of processors
# gtm358			[connellb]	Test bigger keys up to 1023 bytes
# gtm7308			[connellb]	Verify that gvcst_put creates valid index keys
# gtm7327			[rog]		TPNOTACID test - see that we get it when we should and not when we shouldn't
# gtm7231			[zouc]		Test the journal extracting on a journal file which has the database with
#						wc_blocked set
# gtm4525a			[duzang]	Basic configuration test for anticipatory freeze
# gtm4525b			[duzang]	Operational test for anticipatory freeze
# gtm4525c			[base]		Verify freeze happens if predetermined errors are triggered
# gtm6571			[rog]		Verity MUTEXLCKALERT also activates procstuckexec
# dbioerr			[karthikk]	Ensure that GT.M handles disk I/O errors while writing to database file by
#						reporting appropriate errors. Also checks the exit status to be non zero
# gtm6502			[cronem]	Test Max key size up to 1019
# mu_downgrade			[bahirs]	Test mupip downgrade
# wc_blocked			[sopini]	Various wc_blocked-related scenarios
# gtm6779			[base]		Verify zshow "L" does not reset level to 0 after reaching 511 and issues an error
# gtm7402			[nars]		GBLOFLOW error during a KILL causes kill_in_prog/abandoned_kills counter to be
#						incorrect
# gtm7353			[connellb]	Verify indexmod optimization fix
# devopen			[bahirs] 	Test that open command does not generate core.
# gtm7389			[kishore]   	Tests new gvstats (JNL related).
# cut_prev_link			[sopini]	Verify that a link to previous-generation journal file is cut when a user issues a
#						rundown upon a server crash.
# recterm			[base]		Verify that the keys are terminated with a NULL and we get GBLOFLOW when extension
#						count is 0. Also, verify we don't get assert failure due to high t_tries value in
#						wcs_clean_dbsync.
# gtm7219a			[bahirs] 	Verify that image-type, process-type(SRC|RCV|UPD|UPDHELP) and INSTANCE-NAME are
#						part of the facility for operator log messages
# gtm7219b			[bahirs] 	Verify that image-type, process-type(SRC|RCV|UPD|UPDHELP) and INSTANCE-NAME are
#						part of the facility for operator log messages
# gtm7294			[kishoreh] 	space/permission issues with jounal rollback
# gtm7413			[zouc] 		Test the memory allocation when socket openning fails
# mu_upgrade 			[bahirs] 	Test the mupip upgrade to V6 from pre V53003 version handles the master-map change
#						correctly.
# gtm7439 			[karthikk] 	Test to ensure journal extensions don't end up in a unbounded recursive stack
# anticipatory_freeze_utilities	[karthikk]	Verify that instance freeze is honored by various MUPIP utilities
# gtm7398			[cronem] 	<Verify correct jnl_seqno for NULL record insertion after crash and rollback on secondary>
# inst_freeze_enospc		[base]		Instance freeze works if disk space is full
# gtm7383 			[kishoreh] 	No need to write dirty global buffers to database file at epochs when nobefore journaling is in use
#-------------------------------------------------------------------------------------

echo "v60000 test starts..."
# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "gtm4525b gtm7219a"
setenv subtest_list_non_replic "gtm7227 gtm7283 gtm6686 gtm7277 gtm7332 gtm358 gtm7308 C9B12001861 gtm6692 dbioerr gtm4525c "
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7327 gtm7231 gtm4525a gtm6571 gtm6502 gtm6779"
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7402 gtm7353 devopen gtm7389 cut_prev_link recterm gtm7413"
setenv subtest_list_non_replic "${subtest_list_non_replic} mu_downgrade mu_upgrade gtm7439 gtm7383"
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7312 gtm7294 inst_freeze_enospc"
setenv subtest_list_replic     "less_log wc_blocked gtm7219b anticipatory_freeze_utilities gtm7398"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
        setenv subtest_exclude_list "$subtest_exclude_list C9B12001861 gtm4525c gtm6692 dbioerr wc_blocked gtm7219a gtm7219b"
endif

# Filter out tests that will assert fail in dbg
if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7294"
endif

# filter out some subtests for some servers
set hostn = $HOST:r:r:r

# filter out devopen from lester as it does not have /dev/random device
# filter out gtm4525c from lester as it lacks trigger support that the test uses
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list devopen gtm4525c"
endif
# Temporary file system can be created only on linux boxes
if ("linux" != "$gtm_test_osname") then
	setenv subtest_exclude_list "$subtest_exclude_list inst_freeze_enospc"
endif
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list mu_downgrade mu_upgrade"
else if ("dbg" == "$tst_image") then
       # We do not have dbg builds in the range [V50000, V53003] needed by the mu_upgrade subtest so disable it.
       setenv subtest_exclude_list "$subtest_exclude_list mu_upgrade"
       # We do not have dbg V5* builds needed by the mu_downgrade subtest so disable it.
       setenv subtest_exclude_list "$subtest_exclude_list mu_downgrade"
else if ($?ydb_environment_init) then
	# In a YDB environment (i.e. non-GG setup), we do not have prior versions that are needed
	# by the below subtest. Therefore disable it.
       setenv subtest_exclude_list "$subtest_exclude_list mu_upgrade"
endif
# If IGS is not available, filter out tests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7312 gtm7294 inst_freeze_enospc"
endif
if ($?gtm_test_temporary_disable) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm7413"
endif
# Disable certain time-sensitive tests on single-cpu systems
if ($gtm_test_singlecpu) then
	# gtm6571 uses gdb to get C-stack for every MUTEXLCKALERT. It generates MUTEXLCKALERT messages every 30 seconds
	# but we have seen 1-CPU systems run so slow that it takes nearly 3 minutes for a gdb attach/detach sequence
	# to occur resulting in lot more MUTEXLCKALERT messages than the test expects to see and false failures.
	# So disable this subtest on 1-CPU systems.
	setenv subtest_exclude_list "$subtest_exclude_list gtm6571"
endif

#
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh
echo "v60000 test DONE."
