#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
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
#######################################
### instream.csh for sharedlib test ###
#######################################
#
#
# objfile_test		[s7mj]		Subtest for building shared library for huge m file
# gtm6330		[connellb] 	Test DYNAMIC_LITERAL compile mode.
# gtm7905 		[bahirs] 	Verify that JOB process paratemeter -stdout and stderr - present in mumps text
# 					section are not modified by middle process created during JOB command execution.


#######################################
#This test is intended to RUN ONLY ON
#64 BIT MACHINES; it is disabled in
#com/gtmtest.csh for 32 bit (or other
#incompatible) platforms
#######################################


setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv subtest_list "zro_search incr_link excall objfile_test gtm6330 gtm7905"
setenv unicode_testlist "uniexcall shared_lib_unicode_zb incr_link_unicode gtm_chset_recompile"

if (("HOST_LINUX_X86_64" != $gtm_test_os_machtype) && ("HOST_LINUX_ARMV7L" != $gtm_test_os_machtype)			\
		&& ("HOST_AIX_RS6000" != $gtm_test_os_machtype) && ("HOST_SUNOS_SPARC" != $gtm_test_os_machtype)	\
		&& ("HOST_OS390_S390" != $gtm_test_os_machtype) && ("HOST_LINUX_S390X" != $gtm_test_os_machtype)) then
    	setenv subtest_list "$subtest_list dllversion"
endif

if ( "HOST_LINUX_IA64" == $gtm_test_os_machtype || "HOST_LINUX_X86_64" == $gtm_test_os_machtype || "HOST_LINUX_S390X" == $gtm_test_os_machtype) then
    setenv gt_ld_m_shl_options "-shared"
endif
#Added -G option to gt_ld_m_shl_options for produces a shared object
if ( "HOST_SUNOS_SPARC" == $gtm_test_os_machtype) then
	setenv gt_ld_m_shl_options "-G"
endif
if ($LFE == "E") then
	setenv subtest_list "$subtest_list shared_lib_zb shl_relinks shlib_zstep_long shlib_call_ins_extcall"
endif
## test unicode condition ##
if ("TRUE" == $gtm_test_unicode_support) then
	setenv subtest_list "$subtest_list $unicode_testlist"
endif

$gtm_tst/com/submit_subtest.csh

echo "SHAREDLIB tests DONE"
