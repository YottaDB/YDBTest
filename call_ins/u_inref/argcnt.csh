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
# argcnt.csh
#
setenv GTMCI argcnt_less.tab
cat >> $GTMCI << argcnt_less
less_actual : void lessactl^ciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
argcnt_less

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtmci_argcnt_less.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output gtmci_argcnt_less $gt_ld_options_common gtmci_argcnt_less.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
gtmci_argcnt_less
#
setenv GTMCI argcnt_more.tab
cat >> $GTMCI << argcnt_more
more_actual: void moreactl^ciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
argcnt_more

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtmci_argcnt_more.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output argcnt_more $gt_ld_options_common gtmci_argcnt_more.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
argcnt_more
unsetenv GTMCI
