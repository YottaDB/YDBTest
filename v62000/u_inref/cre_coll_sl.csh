#!/usr/local/bin/tcsh
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
#create collation shared libraries for lib_reverse sequences
setenv cur_dir `pwd`
cp $gtm_tst/$tst/inref/col_reverse.c $cur_dir
$gt_cc_compiler -g $gtt_cc_shl_options -I$gtm_inc $cur_dir/col_reverse.c
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/lib_reverse${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/col_reverse.o -lc
setenv gtm_collate_1  "$cur_dir/lib_reverse${gt_ld_shl_suffix}"
