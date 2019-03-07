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
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtmpercent.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output gtmpercent $gt_ld_options_common gtmpercent.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >&! link.map

if( $status != 0 ) then
    cat link.map
endif

rm -f link.map

gtmpercent
unsetenv GTMCI
