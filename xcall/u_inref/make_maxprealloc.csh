# This subtest tests that preallocated value is limited to MAXSTRLEN
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_maxprealloc.c
$gt_ld_shl_linker ${gt_ld_option_output}libmaxprealloc${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_maxprealloc.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_maxprealloc.tab
echo "`pwd`/libmaxprealloc${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
alloc1mb:	void	xc_new_alloc_1mb(O:xc_char_t *[1048578])
xx
