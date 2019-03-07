#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2001-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests that an error will be issued if a sharedlibrary created with version $1 is used with
# the version being tested. Similar to dllversion subtest in sharedlib except this one runs in 64 bit.
#
set dlltest_version = $1
#
# Switch to version
source $gtm_tst/com/switch_gtm_version.csh $dlltest_version $tst_image #$gtm_ver_save will be set to the original version set
#
# Setting gt_ld_m_shl_options is needed because previous versions did not have these
# set in gtm_env_sp.csh for these system types and ver commands overwrites the ones from the instream
#
if ( "HOST_LINUX_IA64" == $gtm_test_os_machtype || "HOST_LINUX_X86_64" == $gtm_test_os_machtype) then
    setenv gt_ld_m_shl_options "-shared"
endif
$gtm_exe/mumps $gtm_tst/$tst/inref/helloworld.m
#
# Link ^helloworld into a shared library and drive it
#
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib helloworld.o ${gt_ld_m_shl_options} >& dllversion_oneversion_ld.outx
rm *.o
setenv gtmroutines "./shlib . .($gtm_tst/$tst/inref)"
$gtm_exe/mumps -run drivehw
rm *.o
#
# switch back to our test version
#
source $gtm_tst/com/switch_gtm_version.csh $gtm_ver_save $tst_image
setenv gtmroutines "./shlib . .($gtm_tst/$tst/inref)"
$gtm_exe/mumps -run drivehw
