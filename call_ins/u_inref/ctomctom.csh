#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ctomctom.csh
#
# call in to M from C
#
setenv GTMCI cmcm.tab
cat >> $GTMCI << cmcm.tab
sqroot: void  sqroot^sqrt2(I:gtm_long_t,I:gtm_long_t)
cube:   gtm_long_t* cubeit^cube(I:gtm_long_t)
cmcm.tab
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/squarec.c
$gt_ld_shl_linker ${gt_ld_option_output}libsquare${gt_ld_shl_suffix} $gt_ld_shl_options squarec.o $gt_ld_syslibs $tst_ld_sidedeck >&! link1.map
if( $status != 0 ) then
    cat link1.map
endif

rm -f  link1.map
rm -f squarec.o

#
# external call to C from M
#
setenv  GTMXC   mcm.tab
echo "`pwd`/libsquare${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
squarec:  xc_long_t   squarec(I:xc_long_t)
xx

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ctomctom.c
$gt_ld_linker $gt_ld_option_output cmcm $gt_ld_options_common ctomctom.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >&! link2.map
if( $status != 0 ) then
    cat link2.map
endif
rm -f link2.map

cmcm
unsetenv GTMCI
unsetenv GTMXC
