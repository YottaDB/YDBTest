#!/usr/local/bin/tcsh
#################################################################
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
#create collation shared libraries for a "straight" sequence ([1-255] -> [1-255])
setenv cur_dir `pwd`
cp $gtm_tst/com/col_$1.c $cur_dir
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $cur_dir/col_$1.c

if ($HOSTOS != "OSF1") then
	$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/lib$1${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/col_$1.o -lc
else
	$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/lib$1${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/col_$1.o -lc -liconv
endif

set col_n = "gtm_collate_$2"
setenv $col_n "$cur_dir/lib$1${gt_ld_shl_suffix}"
setenv gtm_local_collate $2
