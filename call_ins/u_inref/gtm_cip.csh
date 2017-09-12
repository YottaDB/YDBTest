#!/usr/local/bin/tcsh -f
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

setenv GTMCI `pwd`/main.tab
cat >> $GTMCI << maintab
display: void print()
maintab
awk 'BEGIN { for (i=1; i<1000; i++) printf( "display%d: void print%d()\n", i, i) ; exit }' >> $GTMCI

#
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtm_cip.c -I$gtm_inc
$gt_ld_linker $gt_ld_option_output gtm_cip $gt_ld_options_common gtm_cip.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >&! link1.map

if( $status != 0 ) then
    cat link1.map
endif
rm -f link1.map

gtm_cip
unsetenv GTMCI
