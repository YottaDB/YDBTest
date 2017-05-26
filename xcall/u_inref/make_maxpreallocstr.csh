# This subtest tests that preallocated value is limited to MAXSTRLEN
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_maxprealloc.c
$gt_ld_shl_linker ${gt_ld_option_output}libmaxpreallocstr${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_maxprealloc.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_maxpreallocstr.tab
echo "`pwd`/libmaxpreallocstr${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
alloc1mbstr:	void	xc_new_alloc_1mbstr(O:xc_string_t *[1048578])
xx
