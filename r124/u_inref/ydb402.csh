#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that gtm_init(), gtm_ci(), and gtm_cip() can be successfully called to access M code"
echo ""

# Set up function to be called using gtm_ci() and gtm_cip()
cat > test_ci.xc << CAT_EOF
Test: void ydb402()
CAT_EOF

setenv GTMCI test_ci.xc

set file = "ydb402.c"
cp $gtm_tst/$tst/inref/$file .
echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
        echo "YDB402-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
        continue
endif
rm $exefile.o
`pwd`/$exefile
echo ""

