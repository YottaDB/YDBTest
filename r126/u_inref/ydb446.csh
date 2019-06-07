#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that ydb_ci/p() and ydb_ci/p_t() do not sig11 if the M callin return length is greater than the allocated buffer
#

echo '# Test that ydb_ci/p() and ydb_ci/p_t() do not sig11 if the M callin return length is greater than the allocated buffer'

# SETUP of callin files
setenv GTMCI `pwd`/tab.ci
cat >> tab.ci << xx
retStr: ydb_string_t * retStr^retStr()
xx
cat >> retStr.m << xxx
retStr
	quit "a0a1a2a3a4a5a6a7a8a9"
xxx

# SETUP of the driver C files
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb446.c
$gt_ld_linker $gt_ld_option_output ydb446 $gt_ld_options_common ydb446.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& ydb446.map

# Run driver C
`pwd`/ydb446 sapi
`pwd`/ydb446 stapi

