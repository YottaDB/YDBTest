#       make_fcn_percent.csh - setup for external call function starting with % tests.
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_fcn_percent.c

# for AIX, we need to explicitly export the _gtm_fcnpercent function, since it start with an _
if ( $HOSTOS == "AIX" ) then
	echo "_gtm_fcnpercent" > expsym
	setenv gt_ld_shl_options "$gt_ld_shl_options -bE:expsym"
endif
$gt_ld_shl_linker ${gt_ld_option_output}libfcnpercent${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_fcn_percent.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_fcn_percent.tab
echo "`pwd`/libfcnpercent${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
fcnpercent:		void		%gtm_fcnpercent()
xx
