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
#
# Test of ydb_get_s() function for Local variables in the simpleAPI
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=4000 -key_size=1019 -glob=8192

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gvnget1cb.c
$gt_ld_shl_linker ${gt_ld_option_output}libgvnget1cb${gt_ld_shl_suffix} $gt_ld_shl_options gvnget1cb.o $gt_ld_syslibs
\rm gvnget1cb.o
setenv	GTMXC	gvnget1.tab
echo "`pwd`/libgvnget1cb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
gvnget1cb:		void	gvnget1cb()
xx
#
# Drive main M routine
#
$gtm_dist/mumps -run gvnget1
#
set file = "gvnget_errors.c"
echo " --> Running $file <---"
cp $gtm_tst/$tst/inref/$file .
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "GVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif
./$exefile
echo ""
$gtm_tst/com/dbcheck.csh
