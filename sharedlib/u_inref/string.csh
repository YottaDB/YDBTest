#!/usr/local/bin/tcsh -f
$gtm_dist/mumps $gtm_tst/$tst/inref/length.m
setenv LANG "univ.utf8"
#On HPIA64, we see lots of unenecessary warnings for "Variable declared but never used" and after confirmation from Steve, its decided supress these kind of warnings. These are the variables which are used only inside DEBUG* macros but declared for all.
if ( "HOST_HP-UX_IA64" == $gtm_test_os_machtype ) then
    $gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com +W2550 -I$gtm_dist $gtm_tst/$tst/inref/string_xcall.c
else
    $gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/string_xcall.c
endif
$gt_ld_shl_linker ${gt_ld_option_output}libxstring$gt_ld_shl_suffix $gt_ld_shl_options string_xcall.o $gt_ld_syslibs >& string_ld.outx 
#
$gt_ld_m_shl_linker  ${gt_ld_option_output}libmix$gt_ld_shl_suffix string_xcall.o length.o $gt_ld_m_shl_options -lm >>& string_ld.outx
#
rm *.o 
#
#
setenv GTMXC "gtmxc_string.tab"
echo "`pwd`/libxstring$gt_ld_shl_suffix" > $GTMXC
cat >> $GTMXC << xx
wcscat:         void xc_wcscat(I:xc_char_t **, I:xc_char_t **, IO:xc_char_t **)
xx
