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
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_unimaxprealloc.c
$gt_ld_shl_linker ${gt_ld_option_output}libunimaxprealloc${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_unimaxprealloc.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_unimaxprealloc.tab
echo "`pwd`/libunimaxprealloc${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
allocerr:	void	xc_new_alloc_err(O:xc_char_t *[1048578])
xx
