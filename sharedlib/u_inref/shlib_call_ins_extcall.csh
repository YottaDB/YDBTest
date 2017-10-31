#################################################################
#								#
# Copyright 2004, 2014 Fidelity Information Services, Inc	#
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

if ( $HOSTOS == "OS/390" ) then
    # append the desired paths to LIBPATH for call ins to work
    setenv LIBPATH ${tst_working_dir}:${gtm_dist}:.:${LIBPATH}
endif

setenv GTMCI callInSharedLibDriver.tab
cat >> $GTMCI << longtab
callInSharedLibDriver1:  void sharedlib1^callInSharedLibDriver(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
callInSharedLibDriver2:  void sharedlib2lablengthislong678901^callInSharedLibDriver(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
callInSharedLibDriver3:  void extmath^callInSharedLibDriver()
longtab
#
#
# Prepare CALL IN library
#
#
$gt_cc_compiler $gt_cc_option_debug $gtt_cc_shl_options $gtm_tst/$tst/inref/sharedlibc.c -I$gtm_dist
#
$gt_ld_linker $gt_ld_option_output shlibexe $gt_ld_options_common sharedlibc.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
#
# Prepare Shared Library call math^shlib doing EXTERNAL CALL
#
if ($HOSTOS == "SunOS") then
	setenv GTMXC_DLL 1
endif
source $gtm_tst/$tst/u_inref/make_math.csh
#
# Prepare Shared Library used from called in routines
#
$gtm_exe/mumps $gtm_tst/$tst/inref/{shlib.m,lfill.m,mathtst1.m,mathtst2.m,mathtst3.m,verifyargs.m}
$gtm_exe/mumps $gtm_tst/com/{lotsvar.m,longstr.m,examine.m}
$gt_ld_m_shl_linker ${gt_ld_option_output} shl_call_ins$gt_ld_shl_suffix shlib.o lfill.o lotsvar.o longstr.o mathtst1.o mathtst2.o mathtst3.o verifyargs.o examine.o ${gt_ld_m_shl_options} >& shlib_call_ins_extcall_ld.outx
#
$gtm_tst/com/dbcreate.csh mumps 1 255 1008
\rm -f *.o				# Remove object files to make sure they do not get used or interfere with test
#
shlibexe
unsetenv $GTMCI
echo ""
# list object file created
\ls -1 *.o
$gtm_tst/com/dbcheck.csh
