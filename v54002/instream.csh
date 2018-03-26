#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#
# D9K06002779 		[nars] TP restarts due to M-locks should not go on indefinitely
# C9K07003298 		[karthikk] GT.M process that encountered error during db_init should still be interruptible with MUPIP STOP
# C9E11002658 		[rog] check edge case with max legnth names
# D9K07002782 		[estess] test for non-iterating FOR loop on non-shared binary 32 bit platforms
# C9K09003320 		[karthikk] test that MUPIP REPLICATE -INSTANCE_CREATE does NOT rename existing replication instance files
#				in case of errors.
# C9K02003230 		[wdm] Verify dramatic reduction in number of mallocs with hash tab perf improvements
# C9B04001673 		[rog] test boolean handling of side-effects
# zwrite_ztrigger	[karthikk] test that $ZTRIGGER after a ZWRITE works fine when NULL subscripts are allowed
# C9806000511		[rog] test ZWRITE of an ISV
# C9K11003341		[parentel] test that MUPIP INTEG report the correct message when database is misaligned, and that MUPIP EXTEND fix the issue.
# C9K07003300 		[groverh] C stack facility extended to semaphore operations
# D9K05002773           [abs]   block split fill factor
# encrypted_dse_change	[parentel] test that dse change works correctly with encryption
# C9B11001805		[sopini] test that GET_C_STACK_FROM_SCRIPT is properly called and SIGCONT can awake a stopped process
#				 holding the io_in_prog_latch lock
# C9B03001660		[rog] test for with subscripted indirect control variable assigned to an extrinsic that diddles the array it's in
# C9H02002826		[rog] Test various numeric anomalies
# unlink		[estess] Tests unlink (zgoto 0:entry) code to unlink/unwind everything
# zgoto			[estess] Test newly reworked ZGOTO to verify broken-as-designed issues are fixed.
# C9L02003364		[cronem] Test job startup script
# C9K08003318 		[estess] Verify we are creating the YDB_FATAL_ERROR file for fatal signals
# C9905001087 		[nars]   Tests for misc fixes that went in along with the LV project
#-------------------------------------------------------------------------------------

echo "v54002 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "D9K06002779 C9K07003298 C9E11002658 D9K07002782 C9K09003320 C9K02003230 C9B04001673"
setenv subtest_list_non_replic "$subtest_list_non_replic D9K05002773 ztrigger_nullsubs C9806000511 C9K11003341 C9K07003300"
setenv subtest_list_non_replic "$subtest_list_non_replic encrypted_dse_change C9B11001805 C9B03001660 C9H02002826 zgoto"
setenv subtest_list_non_replic "$subtest_list_non_replic C9L02003364 C9K08003318 C9905001087 unlink"
setenv subtest_list_replic     ""
setenv subtest_exclude_list    ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list C9B11001805 C9K07003300"
endif
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list ztrigger_nullsubs"
endif
if ("MM" == "$acc_meth") then
	setenv subtest_exclude_list "$subtest_exclude_list C9K11003341"
endif
if ("NON_ENCRYPT" == "$test_encryption") then
	setenv subtest_exclude_list "$subtest_exclude_list encrypted_dse_change"
endif

# On a non-gg server, filter out tests that require specific GG setup
if ($?gtm_test_noggtoolsdir) then
	# unlink subtest requires $cms_tools/gtmpcatfldbld.csh
	setenv subtest_exclude_list "$subtest_exclude_list unlink"
endif
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v54002 test DONE."
