# 
# gtm_percent.csh
# 
# call in
setenv GTMCI `pwd`/gtmpercent.tab
cat >> $GTMCI << xyz
percent: void %percent^%percent()   ; good
percentw1: void per%cent^%percent() ; wrong - illegal label
percentw2: void percent^perc%ent()  ; wrong - illegal routine
xyz
#
$gt_cc_compiler $gt_cc_options_common $gtm_tst/$tst/inref/gtmpercent.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output gtmpercent $gt_ld_options_common gtmpercent.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >&! link.map

if( $status != 0 ) then
    cat link.map
endif

rm -f link.map

gtmpercent
unsetenv $GTMCI
