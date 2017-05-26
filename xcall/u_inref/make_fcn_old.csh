# 	make_fcn_old.csh - setup for external call function return value tests.
#
#	This is the same as make_fcn.csh except that it declares the function
#	xc_fcn_xc_long() to return a value of type type xc_long_t instead of gtm_long_t.
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_fcn.c
$gt_ld_shl_linker ${gt_ld_option_output}libfcn_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_fcn.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_fcn.tab
echo "`pwd`/libfcn_o${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void		xc_void()
fcnlong:	xc_long_t	xc_fcn_xc_long()
fcnulong:	xc_ulong_t	xc_fcn_xc_ulong()
fcnstat1:	xc_status_t	xc_fcn_xc_status1()
fcnstat2:	xc_status_t	xc_fcn_xc_status2()
fcnint:         xc_int_t	xc_fcn_xc_int()
fcnuint:	xc_uint_t	xc_fcn_xc_uint()
xx
