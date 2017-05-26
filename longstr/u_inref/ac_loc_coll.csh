#! /usr/local/bin/tcsh -f
echo "alternative collation  with long string"
# create collation shared libraries for simple (reverse) sequence
echo "gtm_ac_xform_1 is present, but gtm_ac_xback_1 is missing"
source $gtm_tst/$tst/u_inref/cre_coll_lgstr.csh 1 "col_reverse_1"
$GTM
echo "------------------------------------------------------------"
echo "gtm_ac_xform is present, but gtm_ac_xback is missing"
source $gtm_tst/$tst/u_inref/cre_coll_lgstr.csh 1 "col_reverse_2"
$GTM
echo "------------------------------------------------------------"
echo "neither gtm_ac_xform_1 nor  gtm_ac_xform is present"
source $gtm_tst/$tst/u_inref/cre_coll_lgstr.csh 1 "col_reverse_3"
$GTM
echo "------------------------------------------------------------"
echo "Both gtm_ac_xform_1 and gtm_ac_xback_1 are present"
source $gtm_tst/$tst/u_inref/cre_coll_lgstr.csh 1 "col_reverse_32"
#run some tests with long strings
$GTM << bb
d ^fnlgstr
bb
echo "------------------------------------------------------------"
echo "Both gtm_ac_xform and gtm_ac_xback are present"
source $gtm_tst/$tst/u_inref/cre_coll_lgstr.csh 1 "col_reverse"
$GTM 
echo "------------------------------------------------------------"
echo "Try with subscripts > 32767, which will give error"
$GTM << \aa
s str=$$^longstr(32768)
s abc(str)=1
\aa
