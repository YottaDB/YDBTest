#!/usr/local/bin/tcsh
setenv cur_dir `pwd`
\cp $gtm_tst/com/polish.c $cur_dir
$gt_cc_compiler $gt_cc_shl_options -I$gtm_inc $cur_dir/polish.c >>& polish_collate.out
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libpolish${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/polish.o -lc  >>& polish_collate.out   
if ($?gtm_collate_1 == 0) setenv gtm_collate_1  "$cur_dir/libpolish${gt_ld_shl_suffix}"
