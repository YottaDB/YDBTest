#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# 
# unic2m2c2m.csh
# 
# call in to M from C
$switch_chset "UTF-8"
set dir1 = "multi_ｂｙｔｅ_後漢書_𠞉𠟠_4byte"
\mkdir $dir1
cd $dir1
setenv GTMCI cmcm.tab
cat >> $GTMCI << EOF
concat: void  concat^concat(I:gtm_char_t*,I:gtm_char_t*)
ucase:   gtm_char_t* ucase^ucase(I:gtm_char_t*)
EOF
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/lengthc.c >& compiler.outx
if($status) then 
	echo "TEST-E-COMPILE erros. check compiler.outx"
endif
$gt_ld_shl_linker ${gt_ld_option_output}libconcat${gt_ld_shl_suffix} $gt_ld_shl_options lengthc.o $gt_ld_syslibs $tst_ld_sidedeck >&! link1.map 

if( $status != 0 ) then
    cat link1.map
endif

rm -f  link1.map
rm -f lengthc.o


#
# external call to C from M
#
setenv  GTMXC   mcm.tab
echo "`pwd`/libconcat${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << EOF
lengthc:  xc_long_t   lengthc(I:gtm_char_t*,I:gtm_char_t*)
EOF

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/inref/unic2m2c2m.c
$gt_ld_linker $gt_ld_option_output cmcm_uni $gt_ld_options_common unic2m2c2m.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >&! link2.map

if( $status != 0 ) then
    cat link2.map
endif
rm -f link2.map

cmcm_uni
cd ..
unsetenv GTMCI
unsetenv GTMXC
