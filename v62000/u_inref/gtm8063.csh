#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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

$gt_cc_compiler -o closefds.o $gtt_cc_shl_options $gt_cc_option_debug $gtm_tst/$tst/inref/closefds.c
$gt_ld_linker $gt_ld_option_output closefds $gt_ld_options_common $gt_ld_options_dbg closefds.o $gt_ld_sysrtns $gt_ld_syslibs >& makeexe.out

# Run mumps with combinations of stdin/stdout/stderr descriptors closed
(./closefds $gtm_exe/mumps -r gtm8063 < /dev/null >> closefds.out) >& closefds.err

$grep -E '(PASS|FAIL)' closefds_[0-7].out
