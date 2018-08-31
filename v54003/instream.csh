#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
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
# ------------------------------------------------------------------------------------
# zshowintr		[estess]	Verify that an interrupted ZSHOW command resumes correctly (C9J06-003137)
# C9L03003393 		[Karthik]	Ensure gv_target is properly reallocated when view "NOISOLATION" is used before first db operation
# C9L03003394		[rog]		Check $REFERENCE after MERGE
# ossmake		[shaha]		Test the makefile builds regularly so that we know when they break --> moved to manually_start
# zhalt			[estess]	Test new ZHALT <rc> command
# D9L04002809 		[Karthik]	Test that receiver server does NOT hang when a older update process is killed
# C9L04003407		[Narayanan]	blk-split heuristic should be cleaned up for directory tree too in case of TP restart
# C9K08003315		[parentel]	Test JNLBADRECFMT with same jnl file is specified twice and repeated Y/N messages in forward recovery.
# C9L05003412		[nars]		GVSUBOFLOW/GVIS error should not print garbage in subscripts
#					This test takes 7 minutes to run on snail (our slowest box) so do not include it for L_ALL
# dbjnlsync_clean1	[Bahirs]	Test that out of sync backward recovery is not done when database is cleanly shutdown
# dbjnlsync_clean2	[Bahirs]	Test that out of sync backward recovery is not done when database is cleanly shutdown
# dbjnlsync_clean3	[Bahirs]	Test that out of sync backward recovery is not done when database is cleanly shutdown
# dblagjnl_crash	[Bahirs]	Test that out of sync backward recovery is not done when database is crashed
# dbaheadjnl_crash1	[Bahirs]	Test that backward recovery is done if database is ahead of or in sync with journaling when database is crashed
# dbaheadjnl_crash2	[Bahirs]	Test that out of sync backward recovery is not done when database is crashed
# C9J03003100   	[parentel]	Test that recovery failing with NOPREVLINK don't set the db corrupt flag
# dbidmismatch1.csh   	[Bahirs]	Test DBIDMISMATCH error in mupip rundown -reg *"
# dbnammismatch1.csh  	[Bahirs]	Test DBNAMEMISMATCH error in mu_rndwn_file"
# dbnammismatch2.csh  	[Bahirs]	Test DBNAMEMISMATCH error in mu_rndwn_file"
# dbshmmismatch1.csh  	[Bahirs]	Test DBSHMMISMATCH error"
# dbshmmismatch2.csh  	[Bahirs]	Test DBSHMMISMATCH error"
# shmsemremlog.csh    	[Bahirs]	Test if shared memory removal and semaphore removal is logged in operator log"
# C9K12003344 		[Karthik] 	Ensure that JOURNAL RECOVER resets cs_data->fully_upgraded correctly
# C9H04002840 		[sopini]	Ensure that mutex_wakeup does not error out on EPERM error and uses continue_proc instead
# D9I12002716		[parentel]	Test that source server close older journal files after a period of inactivity
# etrapinfinalretry	[shaha]		GET/SET inside an $ETRAP in the final retry
# transbig1		[bahirs]	Verify that crossing 64K block read-set limit and write-set limit(half of the global
#                                       buffers), issues TRANS2BIG error.
# transbig2		[bahirs]	Verify that crossing 32K block write-set limit, issues TRANS2BIG error.
# D9L06002816		[Narayanan]	op_gvrectarg should keep sgm_info_ptr and first_sgm_info in sync
# incrollback		[bahirs]	Verify that increment rollback creates enough room for additional global references.
# dsejnlrectype		[bahirs]	Verify that asterisk is not printed in dse dump -file -all output
# dbinit_honor_userwait [Karthik] 	New test case for db init enhancement to allow for waits during semop(). Previously, the
#					waits were fixed and were not present for access control semaphore
# incrollback		[bahirs]	Verify that increment rollback creates enough room for additional global references.
# dsejnlrectype		[bahirs]	Verify that asterisk is not printed in dse dump -file -all output
# C9I12003062 		[Karthik] 	Test that out-of-sync values for access method between global directory and database
#                                       is properly handled by GT.M in gvcst_init/db_init
# C9J03003101		[parentel]	Test that source server issue an error if it can't find seqno in journal files
# D9I08002697		[duzang]	Verify upgrade to new gld format and test larger maximum journal extension
# deferred_mupip_stop	[sopini] 	Verify that MUPIP STOP is deferred when DEFER_INTERRUPTS is used; and that three
#                                       MUPIP STOPs still terminate the process
# C9I05002991		[duzang]	test skipping unknown commands with false postconditionals
# C9K11003340		[sopini]	Test deferred timers functionality
# db1tb			[estess]	Test some utilities for issues when DB size > 1TB
# gtm6957		[rog]		Check $ZTRNLNM() keyword handling
# maxregseqno 		[bahirs] 	Test that if -updateresync is specified and if the secondary max-reg-seqno is GREATER
#                                       than primary max-reg-seqno, REPL_ROLLBACK_FIRST error is issued
# indrindrdo            [estess]        GTM-7008 - Test indirect DO inside XECUTE string for correct functioning
# gtm6994		[duzang]	Test 64-bit call-out and call-in
# C9L06003421       	[Bahirs]    	Test that in tp_resolve_time calculations only those regions will participate which were open
#                               	at the time of crash.
# resync            	[Bahirs]    	Test that fetchresync and resync qualifier for rollback behaves similarly and approx use same
#					amount of memory
# gtm6811		[duzang]	Verify that mumps and mupip error out if an older version using semaphores with the old ftok
#					key is in use
# callerid		[Bahirs]	Verify that if the callerid stub is used, 0xFFFFFFFF is sent as 'generated from' address to
#					operator log
#----------------------------------------------------------------------------------------------------

echo "v54003 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "zshowintr C9L03003393 C9L03003394 zhalt C9L04003407 C9K08003315 dbjnlsync_clean1 dbjnlsync_clean2"
setenv subtest_list_non_replic "$subtest_list_non_replic dbjnlsync_clean3 dblagjnl_crash dbaheadjnl_crash1 dbaheadjnl_crash2"
setenv subtest_list_non_replic "$subtest_list_non_replic C9J03003100 dbnammismatch1 dbnammismatch2 dbshmmismatch1 dbshmmismatch2"
setenv subtest_list_non_replic "$subtest_list_non_replic dbidmismatch1 shmsemremlog"
setenv subtest_list_non_replic "$subtest_list_non_replic C9K12003344 C9H04002840 etrapinfinalretry D9L06002816 transbig1 transbig2"
setenv subtest_list_non_replic "$subtest_list_non_replic incrollback dsejnlrectype dbinit_honor_userwait C9I12003062 D9I08002697"
setenv subtest_list_non_replic "$subtest_list_non_replic deferred_mupip_stop C9I05002991 C9K11003340 gtm6957 indrindrdo gtm6994 C9L06003421"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm6811"
setenv subtest_list_replic     "D9L04002809 C9J03003101 maxregseqno resync"
setenv subtest_list_non_replic_FE "C9L05003412 db1tb"
setenv subtest_list_replic_FE  "D9I12002716"

# only HP-UX_IA64 and OSF1 uses caller_id stub so run this test only for these platform
if (("HOST_HP-UX_IA64" == "$gtm_test_os_machtype") || ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype")) then
        setenv subtest_list_non_replic "$subtest_list_non_replic callerid"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
	if ("L" != $LFE) then
		setenv subtest_list "$subtest_list $subtest_list_replic_FE"
	endif
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
	if ("L" != $LFE) then
		setenv subtest_list "$subtest_list $subtest_list_non_replic_FE"
	endif
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list C9H04002840 dbinit_honor_userwait deferred_mupip_stop C9K11003340"
endif

# Only run these on non-MSEM machines
if ("HOST_OS390_S390" != "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list C9H04002840"
endif

# HPPA does not do triggers, so exclude subtests that require $ztrigger functionality
# HPPA does not support MM. Disable subtest that runs ONLY with MM
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list	"$subtest_exclude_list C9L04003407"
endif

# AIX and SunOS limit lsof's path/filename display to few enough chars, they usually are not useful so exclude the
# test(s) that require this.
# HPPA has a problem with multiple invocations of lsof so don't run
if (("HOST_AIX_RS6000" == "$gtm_test_os_machtype") || ("HOST_SUNOS_SPARC" == "$gtm_test_os_machtype") ||  ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype")) then
	setenv subtest_exclude_list	"$subtest_exclude_list D9I12002716"
endif

# SunOS can't handle > 1TB files with its default UFS file system
if ("HOST_SUNOS_SPARC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list	"$subtest_exclude_list db1tb"
endif

# beowulf has an issue with MM (check mails with subject : "Weird MM issues on Beowulf"). Disable MM tests temporarily
# MM is not supported on HPPA. So, disable it on HPPA as well.
if ("beowulf" == "$HOST:r:r:r" || ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype")) then
	setenv subtest_exclude_list	"$subtest_exclude_list C9I12003062"
endif
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list D9I08002697 gtm6811"
else if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	if ("dbg" == "$tst_image") then
		# We do not have dbg V54002B builds needed by the gtm6811 subtest so disable it.
		setenv subtest_exclude_list "$subtest_exclude_list gtm6811"
	endif
	# Temporarily disable below subtest as it requires "gld_mismatch" prior version which will be there once T63002 is released.
	setenv subtest_exclude_list "$subtest_exclude_list D9I08002697"
endif

if ($?gtm_test_temporary_disable) then
	# We have seen the below test hang with V63000A_R100/T63000. And hope this will not happen with
	# V63001A_R100/T63001A or V63002_R100/T63002. So disabling this until then.
	setenv subtest_exclude_list "$subtest_exclude_list D9L04002809"
endif

if ("ENCRYPT" == $test_encryption) then
	# This test does not ship databases across hosts, but it renames databases
	# Sourcing the below script would result in both the databases using the same key and hence would work
	source $gtm_tst/com/create_sym_key_for_multihost_use.csh
endif

# A lot of subtests expect YDB-E-REQRUNDOWN error. But running with journling on would throw YDB-E-REQRECOV error
# Until the individual tests are changed to handle both, disable journaling
setenv gtm_test_jnl NON_SETJNL

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v54003 test DONE."
