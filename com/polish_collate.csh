#!/usr/local/bin/tcsh
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
setenv cur_dir `pwd`
\cp $gtm_tst/com/polish.c $cur_dir
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $cur_dir/polish.c >>& polish_collate.out
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libpolish${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/polish.o -lc  >>& polish_collate.out   
if ($?gtm_collate_1 == 0) setenv gtm_collate_1  "$cur_dir/libpolish${gt_ld_shl_suffix}"
