#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# multi_gtm_init.csh
#
setenv GTMCI cmm.tab
cat >> $GTMCI << CMM_EOF
square:gtm_long_t*  squar^square(I:gtm_long_t)
CMM_EOF

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/multi_init.c
$gt_ld_linker $gt_ld_option_output multi $gt_ld_options_common multi_init.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f link.map
`pwd`/multi
unsetenv GTMCI

