#!/usr/local/bin/tcsh
#create collation shared libraries for a "straight" sequence ([1-255] -> [1-255])
setenv cur_dir `pwd`
cp $gtm_tst/com/col_straight.c $cur_dir
$gt_cc_compiler $gt_cc_shl_options -I$gtm_inc $cur_dir/col_straight.c
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libstraight${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/col_straight.o -lc

set col_n = "gtm_collate_$1"
setenv $col_n "$cur_dir/libstraight${gt_ld_shl_suffix}"
setenv gtm_local_collate $1
