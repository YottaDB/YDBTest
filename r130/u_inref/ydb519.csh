#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This tests opening sockets to determine if YottaDB is honoring the user-specified timeout values.

# Compile ydb519.c and make it a .so file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb519.c
$gt_ld_shl_linker ${gt_ld_option_output}libydb519${gt_ld_shl_suffix} $gt_ld_shl_options ydb519.o $gt_ld_syslibs

#set up the xcall environment
setenv ydb_xc ydb519.tab
setenv GTMXC ydb519.tab
setenv  my_shlib_path `pwd`
echo '$my_shlib_path'"/libydb519${gt_ld_shl_suffix}" > $ydb_xc
cat >> $ydb_xc << xx
getMonoTimer: gtm_int_t x_mono_timer()
xx

# Call the M code
$ydb_dist/mumps -run ^ydb519sock
