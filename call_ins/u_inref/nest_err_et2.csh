#
# nest_err_et2.csh
#       
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/nesterr.c
$gt_ld_shl_linker ${gt_ld_option_output}libnesterr1${gt_ld_shl_suffix} $gt_ld_shl_options nesterr.o $gt_ld_syslibs $tst_ld_sidedeck >&! link1.map 

if( $status != 0 ) then
    cat link1.map
endif

rm -f link1.map
rm -f nesterr.o

#
# external call
#
setenv	GTMXC	mtoc1.tab
echo "`pwd`/libnesterr1${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
inmult:		void	xc_inmult(I:xc_float_t *, I:xc_double_t *, I:xc_char_t *, I:xc_char_t **, I:xc_string_t *)
xx
#
# call_in
# 
setenv GTMCI ctom.tab
cat >> $GTMCI << yy
divbyzro:  void ^divzro3()
yy
unsetenv $GTMCI
#
#
$GTM <<EOF
Write "Do ^nestet1",!  Do ^nestet1
Halt
EOF
unsetenv GTMXC
