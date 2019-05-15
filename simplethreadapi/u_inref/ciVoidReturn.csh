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
#
# Test of ydb_ci() when taking a string as a parameter, and returning void, properly processes the string parameter
#

echo '# Test of ydb_ci() when taking a string as a parameter, and returning void, properly processes the string parameter'

#SETUP of the driver C file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ciVoidReturn.c
$gt_ld_linker $gt_ld_option_output ciVoidReturn $gt_ld_options_common ciVoidReturn.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& ciVoidReturn.map

cp $gtm_tst/$tst/inref/ciVoidReturnH.m .

setenv GTMCI `pwd`/ciVoidReturn.tab
echo $GTMCI
cat >> ciVoidReturn.tab << xx
ciStringProc: void ciStringProc^ciVoidReturnH(I:ydb_string_t*,I:ydb_long_t)
xx

$gtm_tst/com/dbcreate.csh mumps

# Run driver C
`pwd`/ciVoidReturn

$gtm_tst/com/dbcheck.csh
