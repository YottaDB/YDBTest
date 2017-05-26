#       make_fcn.csh - setup for external call function return value tests.
#       This table maps all the gtm types as defined in $gtm_dist/gtmxc_types.h
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_fcn.c
$gt_ld_shl_linker ${gt_ld_option_output}libfcn${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_fcn.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_fcn.tab
echo "`pwd`/libfcn${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void		gtm_void()
fcnlong:	gtm_long_t	gtm_fcn_gtm_long()
fcnulong:	gtm_ulong_t	gtm_fcn_gtm_ulong()
fcnstat1:	gtm_status_t	gtm_fcn_gtm_status1()
fcnstat2:	gtm_status_t	gtm_fcn_gtm_status2()
fcnint:	        gtm_int_t	gtm_fcn_gtm_int()
fcnuint:	gtm_uint_t	gtm_fcn_gtm_uint()
xx
