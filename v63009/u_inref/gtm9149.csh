#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
set syslog_begin = `date +"%b %e %H:%M:%S"`

echo "# Compile gtm9149.c and make it a .so file"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtm9149.c
$gt_ld_shl_linker ${gt_ld_option_output}libgtm9149${gt_ld_shl_suffix} $gt_ld_shl_options gtm9149.o $gt_ld_syslibs

echo "# Set up the xcall environment"
setenv ydb_xc gtm9149.tab
setenv GTMXC gtm9149.tab
setenv  my_shlib_path `pwd`
echo '$my_shlib_path'"/libgtm9149${gt_ld_shl_suffix}" > $ydb_xc
cat >> $ydb_xc << xx
printSuccess: gtm_string_t* fun()
xx
cat >> gtm9149M.m << xxx
	set x=\$&printSuccess()
	write x
xxx

echo "# This test makes an external call that returns a negative length string which should produce a ZCCONVERT error"

$ydb_dist/mumps -run ^gtm9149M
