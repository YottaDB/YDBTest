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
echo "# Test that after calling ydb_zwr2str_s()/ydb_zwr2str_st(), no subsequent SimpleAPI/SimpleThreadAPI calls get a SIMPLAPINEST error."
echo ""


set file = "ydb344.c"
cp $gtm_tst/$tst/inref/$file .
echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
        echo "SIMPLEAPINEST-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
        continue
endif
rm $exefile.o
`pwd`/$exefile
echo ""

