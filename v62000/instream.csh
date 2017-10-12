#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
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
#-------------------------------------------------------------------------------------
# gtm7953		[nars]		SIG-11 in $ZPREVIOUS of gvn with nullsubs as last subscript AND subscripted gvn spans
# 					multiple regions AND region has maxkeysize >= 999.
# gtm7963		[nars]		SIG-11 in $QUERY of lvn after an UNDEF error.
# gtm7740		[bahirs]        Verify that shared collation library is protected against buffer overflow.
# gtm7975		[nars]		m**n gives incorrect positive result for large odd n and -1 ~<= m < 0.
# gtm7919		[sopini]	Test to ensure that all currently defined GT.M messages are printed correctly in the
# 					terminal or syslog, and that argument overflows and type coercions happen as expected.
# gtm7984andgtm7983	[nars]		Test that MUPIP JOURNAL -EXTRACT extracts jnl records > 32Kb in size.
#					Also test that DSE DUMP -GLO/-ZWR correctly extracts unsubscripted nodes.
#					Also test that piping the output of GT.M or MUPIP or DSE that has lines longer than 32Kb now works fine.
#					Also test that ZSHOW D for pipe devices display STREAM/NOWRAP as appropriate.
# gtm7976		[base]		Verify that turning journaling on a backed up database does not end up with JNLRDONLY error if there's
#					no reason to do modifications on the former journal file.
# gtm8002 		[nars]		WRITE /EOF of PIPE device without an immediately following CLOSE later causes EBADF and/or database corruption
# gtm8013		[duzang]	SIG-11 in iosocket_wait after connect on local socket
# zsyslog		[estess]	Test for $ZSYSLOG() for GTM-7999.
# gtm7988		[base]		Verify that zwrite does not issue a (GV)UNDEF error.
# gtm7824 		[karthikk]	Test that ONLINE INTEG robustly handles cases where phase2 commit failures and file extensions can happen
# gtm8027		[nars]		SIG-11 in $VIEW("REGION",argument) if argument is the null string
# gtm8001		[rog]		add test of revised functionality - i.e. to skip the call when there is no change
# gtm8036		[rog]		add test of some patcode errors
# gtm7971		[rog]		test that extrinics in Booleans compiled with gtm_boolean (full_boolean) don't indefinite loop
# zsyslog		[estess]	Test for $ZSYSLOG() for GTM-7999.
# gtm8015		[rog]		Add test of gtm_boolean and gtm_side_effects environment variable value handling and gtm_boolean VIEW/$VIEW() interaction
# gtm7569		[rog]		Add test of MAXBTLEVEL from gvcst_put
# gtm8047		[nars]		GTM-E-MEMORY errors during non-mandatory stringpool expansion result in no garbage collection
# gtm8065		[rp]		Check that JOB detects an undefined lvn
# gtm8083		[nars]		TXTSRCMAT error inside trigger code + TP restarts does not cause SIG-11 anymore
#					This also tests GTM-8085
# gtm8084		[nars]		Test of MUPIP INTEG -BLOCK
# gtm8075		[nars]		Test that buffer expansion for external and internal filters works fine in source/receiver server
# gtm8092		[nars]		SIG-11 during SET of 1Mb-sized global nodes in replicated database and journal pool size is close to 1Mb
#					Also tests <gtmsource_msgp_assert_failures_in_source_server>
# gtm8095		[nars]		Buffer overflows in source server in rare cases with multiple regions and huge transactions (> 3Mb jnl record size)
# gtm7897		[duzang]	Test access to database on read-only mounted filesystem
# gtm7928zcall		[shaha]		Test that $ZCALL() results in an FNOTONSYS on all Unix platforms even though only Solaris supported it previously
# gtm8063		[duzang]	Test that missing stdin/stdout/stderr file descriptor is filled in
# gtm8108		[nars]		Test various cases where $data(active_lv) = 0 which in turn caused $query to SIG-11; Also includes one test for GTM-8064
# gtm8114		[nars]		Test runtime error after a TP restart does not SIG-11
# gtm8115		[rp]		Test that BREAK and NEW with postconditions after a FOR don't explode
# gtm8116		[nars]		Test that $TEXT returns silently in case of error (no incorrect TPQUIT errors etc.)
# gtm7547		[base]		Verify $etrap retains the same value when new'ed. Verify call-in functions respect etrap when it is set by the gtm_etrap environment variable
# gtm6348		[rp]		Test that cert_blk failure in wcs_recover produces a DBDANGER error
# gtm8070		[rp]		Test that TP + LOCK does not block the exit of a conflicting lock
# gtm7003		[rp]		Test that for GOTOs LABELUNKNOWN does not explode and we get LABELNOTFND instead
# gtm8003		[rp]		Test <CTRL-C> behavior with [no]cenable and $ctrp=$c(3)
# gtm7926*		[shaha]		Various tests that validate $gtm_dist
# gtm8121		[nars]		Test that MUPIP RUNDOWN does not issue DBFLCORRP error
# gtm8128		[rp]		Test that MUPIP EXTRACT handles more than 2**31 records without overflow using white box case 68
# gtm8118		[nars]		Test that Source server sends transactions in timely fashion when reading from journal files
# gtm8111		[connellb]	Test EMBED_SOURCE mumps qualifier
# zparse		[sopini]	Test that '..' in $gtmroutines and when provided to $zparse() is processed correctly.
# jobcmdDollarxTest 	[e1060245] 	Test to ensure that a NEWLINE is not inserted when a job is started for various I/O devices. Ref:[GTM-8123]
# machinelist		[connellb]	Basic sanity test for mumps -machine -list
# gtm8154		[rp]		Test DSE FIND -BLOCK -EXHAUSTIVE works on blocks with no valid keys
# gtm8023 		[kishoreh] 	Test that MUMPS read-only processes can transition to read-write processes when secondary instance is activated (i.e. becomes a primary) on-the-fly
# sym			[shaha]		Ensure that gtm_dist uses the symlink path when EXECing other processes
# gtm8145		[rp]		Test ZHELP and utility HELP interaction with CTRL-C
# gtm8086		[duzang]	Test read-only journal dir with inst_freeze_on_error/error_on_jnl_file_lost
# gtm8142		[duzang]	Test race between db_init and rundown with encryption and gld/fileheader out of sync
#-------------------------------------------------------------------------------------

echo "v62000 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "gtm8121 gtm8086"
setenv subtest_list_non_replic "gtm7953 gtm7963 gtm7740 gtm7975 gtm7919 gtm7984andgtm7983 gtm7976 gtm8002 gtm8013 zsyslog gtm7988"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7824 gtm8027 gtm8001 gtm8036 gtm7971 gtm8015"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7569 gtm8047 gtm8065 gtm8083 gtm8084 gtm7897 gtm7928zcall gtm8063"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8108 gtm8114 gtm8115 gtm8116 gtm7547 gtm6348 gtm8070 gtm7003 gtm8003"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7926callins gtm7926isgtmdist gtm7926maxpath gtm7926rcvr gtm8128 gtm8111"
setenv subtest_list_non_replic "$subtest_list_non_replic zparse jobcmdDollarxTest machinelist gtm8154 sym gtm8145 gtm8142"
setenv subtest_list_replic     "gtm8075 gtm8092 gtm8095 gtm8118 gtm8023 "

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out white-box tests that cannot run in pro.
if ("pro" == "$tst_image") then
        setenv subtest_exclude_list "$subtest_exclude_list gtm7919 gtm7824 gtm8128 gtm6348"
endif

# Filter out certain subtests for some servers.
set hostn = $HOST:r:r:r

# Do not run gtm7919 on carmen, titan, pfloyd, or strato because their syslog daemon starts dropping messages
# when the rate exceeds a certain threshold.
if (("carmen" == "$hostn") || ("titan" == "$hostn") || ("pfloyd" == "$hostn") || ("strato" == "$hostn")) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7919"
endif

# gtm7897 required IGS ROBINDMOUNT (Linux >= 2.6.26) or IGS SNAPSHOT/SSMOUNT (AIX)
if (("$gtm_test_os_machtype" !~ HOST_{LINUX_{IX86,X86_64},AIX_RS6000,SUNOS_SPARC}) || ("$hostn" =~ {jackal,charybdis})) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7897"
endif

# If IGS is not available, filter out tests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7897 gtm7926maxpath"
endif

# Exclude tests which require BG
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8086"
endif

# Filter out tests that don't work on i386
if ("HOST_LINUX_IX86" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list	"$subtest_exclude_list machinelist"
endif

# Exclude tests which require encryption
if ("NON_ENCRYPT" == $test_encryption) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8142"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7926rcvr"
else if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	if ("dbg" == "$tst_image") then
		# We do not have dbg builds of versions [...,V61000] needed by the below subtest so disable it.
		setenv subtest_exclude_list "$subtest_exclude_list gtm7926rcvr"
	endif
endif
if ($?gtm_test_temporary_disable) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm7926isgtmdist"
endif
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v62000 test DONE."
