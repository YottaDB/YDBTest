#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2017, 2023 YottaDB LLC and/or its subsidiaries.	#
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
cp $gtm_tst/$1 $cur_dir
set colfullrtnname = $1:t           # This is the local name after copying it - shave off the path
set colrtnname = $colfullrtnname:r  # This is the name sans extension but still has col_ prefix
set colname = `echo $colrtnname | $gtm_dist/mumps -run ^%XCMD 'read x write $zpiece(x,"col_",2)'`
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $cur_dir/$colfullrtnname
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/lib$colname${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/$colrtnname.o -lc

set col_n = "gtm_collate_$2"
setenv $col_n "$cur_dir/lib${colname}${gt_ld_shl_suffix}"
setenv gtm_local_collate $2
