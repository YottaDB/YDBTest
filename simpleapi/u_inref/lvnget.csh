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
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/lvnget1cb.c
$gt_ld_shl_linker ${gt_ld_option_output}liblvnget1cb${gt_ld_shl_suffix} $gt_ld_shl_options lvnget1cb.o $gt_ld_syslibs
\rm lvnget1cb.o
setenv	GTMXC	lvnget1.tab
echo "`pwd`/liblvnget1cb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
lvnget1cb:		void	lvnget1cb()
xx
#
# Drive main M routine
#
$gtm_dist/mumps -run lvnget1
#
set file = "lvnget_errors.c"
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
