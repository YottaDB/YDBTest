#! /usr/local/bin/tcsh -f
#################################################################
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
# tests that an error will be issued if a sharedlibrary created with version $1 is used with
# the version being tested.

set dlltest_version = $1
# switch to version
source $gtm_tst/com/switch_gtm_version.csh $dlltest_version $tst_image #$gtm_ver_save will be set to the original version set

# Setting gt_ld_m_shl_options is needed because previous versions did not have these
# set in gtm_env_sp.csh for these system types and ver commands overwrites the ones from the instream
if ( "HOST_LINUX_IA64" == $gtm_test_os_machtype || "HOST_LINUX_X86_64" == $gtm_test_os_machtype) then
    setenv gt_ld_m_shl_options "-shared"
endif
if ( "HOST_SUNOS_SPARC" == $gtm_test_os_machtype) then
        setenv gt_ld_m_shl_options "-G"
endif
$gtm_exe/mumps $gtm_tst/$tst/inref/avg.m

$gt_ld_m_shl_linker ${gt_ld_option_output} shlib avg.o ${gt_ld_m_shl_options} >& dllversion_oneversion_ld.outx
rm *.o
setenv gtmroutines "./shlib"

$GTM << eof
w \$ZV,!
do ^avg
halt
eof

# switch back to V5 version
source $gtm_tst/com/switch_gtm_version.csh $gtm_ver_save $tst_image
setenv gtmroutines "./shlib"
$GTM << eof
w \$ZV,!
do ^avg
eof
