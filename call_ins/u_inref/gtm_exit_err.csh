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
# gtm_exit_err.csh
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtm_exit.c
$gt_ld_shl_linker ${gt_ld_option_output}libexit${gt_ld_shl_suffix} $gt_ld_shl_options gtm_exit.o $gt_ld_syslibs $tst_ld_sidedeck >&! link1.map

if( $status != 0 ) then
    cat link1.map
endif

rm -f link1.map
rm -f gtm_exit.o

#
# external call
#
setenv	GTMXC	mtoc1.tab
echo "`pwd`/libexit${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
inmult:		void	xc_inmult(I:xc_float_t *, I:xc_double_t *, I:xc_char_t *, I:xc_char_t **, I:xc_string_t *)
xx
#
# call_in
#
setenv GTMCI err.tab
cat >> $GTMCI << yy
divbyzro:  void ^divzro2()
yy
#
$GTM <<EOF
Write "Do ^gtmexit",!  Do ^gtmexit
Halt
EOF
unsetenv GTMXC
unsetenv GTMCI
