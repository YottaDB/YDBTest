#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#This tests ydb_init() to determine if it sets $gtm_dist when $ydb_dist is set and $gtm_dist is not set or set to a different value.

#make $gtm_dist undefined
unsetenv gtm_dist

# Compile and link ydb470.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb470.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb470 $gt_ld_options_common ydb470.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
ydb470

#set $gtm_dist to a non-existent version of GT.M
setenv gtm_dist "/usr/library/old_gtm_version"

# Compile and link ydb470.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb470.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb470 $gt_ld_options_common ydb470.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
ydb470

#restore the correct value of $gtm_dist
setenv gtm_dist $ydb_dist
