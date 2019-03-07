#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#create collation shared libraries for polish and rev_polish sequences
setenv cur_dir `pwd`
cp $gtm_tst/$tst/u_inref/polish.c $cur_dir
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $cur_dir/polish.c
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libpolish${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/polish.o -lc

cp $gtm_tst/$tst/u_inref/polish_rev.c $cur_dir
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $cur_dir/polish_rev.c
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libpolish_rev${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/polish_rev.o -lc

setenv gtm_collate_1  "$cur_dir/libpolish${gt_ld_shl_suffix}"
setenv gtm_collate_2  "$cur_dir/libpolish_rev${gt_ld_shl_suffix}"


setenv | grep coll >! env_individual.txt
