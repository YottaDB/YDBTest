#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Compile the utils external calls library and prepare the enrivonment for its use in a test.

$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_debug -I$gtm_dist $gt_cc_option_I $gtm_tst/com/xcall_utils.c -o utils.o
$gt_ld_shl_linker ${gt_ld_option_output}libutils${gt_ld_shl_suffix} $gt_ld_shl_options utils.o $gt_ld_sysrtns $gt_ld_syslibs

setenv GTMXC_utils $PWD/utils.xc
cat > $GTMXC_utils <<EOF
$PWD/libutils${gt_ld_shl_suffix}
setrlimit:	gtm_status_t set_rlimit(I:gtm_int_t, O:gtm_int_t *)
EOF
