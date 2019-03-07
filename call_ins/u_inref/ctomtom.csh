#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ctomtom.csh
#
setenv GTMCI cmm.tab
cat >> $GTMCI << cmm.tab
chngbase: gtm_char_t*  base^base(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
cmm.tab
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ctomtom.c
$gt_ld_linker $gt_ld_option_output ctmm $gt_ld_options_common ctomtom.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
ctmm
unsetenv GTMCI

