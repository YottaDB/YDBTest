#!/usr/local/bin/tcsh
#create collation shared libraries for a "reverse" sequence ([1-255] -> [255-1])
#This script is simply lifted from $gtm_test/T990/com/cre_coll_sl_reverse.csh with just the if clause added
setenv cur_dir `pwd`
if !(-e libreverse${gt_ld_shl_suffix}) then
	cp $gtm_tst/com/col_reverse.c $cur_dir
	$gt_cc_compiler $gt_cc_shl_options -I$gtm_inc $cur_dir/col_reverse.c
	$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libreverse${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/col_reverse.o -lc
endif
set col_n = "gtm_collate_$1"
setenv $col_n "$cur_dir/libreverse${gt_ld_shl_suffix}"
setenv gtm_local_collate $1

