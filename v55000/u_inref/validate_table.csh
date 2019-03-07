#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv cur_dir `pwd`
\cp $gtm_tst/$tst/inref/comp_tab.c $cur_dir
\cp $gtm_ver/src/jnl_get_checksum.c $cur_dir
echo "$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_I $cur_dir/comp_tab.c" >&! compile1.log
$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_I $cur_dir/comp_tab.c >>&! compile1.log
if ($status) then
	echo "TEST-E-CC Error while trying to compile comp_tab.c"
	exit 1
endif
echo "$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_I $cur_dir/jnl_get_checksum.c"  >&! compile2.log
$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_I $cur_dir/jnl_get_checksum.c  >>&! compile2.log
if ($status) then
	echo "TEST-E-CC Error while trying to compile jnl_get_checksum.c"
	exit 1
endif
$gt_cc_compiler $gt_ld_options_common -o $cur_dir/validate_table $cur_dir/comp_tab.o  $cur_dir/jnl_get_checksum.o >&! linking.log
if ($status) then
	echo "TEST-E-LINK Error while trying to link comp_tab.o"
	exit 1
endif
$cur_dir/validate_table
