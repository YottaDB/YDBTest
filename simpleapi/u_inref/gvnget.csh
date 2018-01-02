#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_get_s() function for Global variables in the simpleAPI
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=4000 -key_size=1019 -glob=8192

echo "# Run gvngetcb.m first since it is driven by an M routine"
echo " --> Running gvngetcb.m <--"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gvngetcb.c
$gt_ld_shl_linker ${gt_ld_option_output}libgvngetcb${gt_ld_shl_suffix} $gt_ld_shl_options gvngetcb.o $gt_ld_syslibs
\rm gvngetcb.o
setenv	GTMXC	gvngetcb.tab
echo "`pwd`/libgvngetcb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
gvngetcb:		void	gvngetcb()
xx
$gtm_dist/mumps -run gvngetcb

echo ""
echo "# Now run gvnget*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/gvnget*.c .
set drivenbyMlist = "gvngetcb.c" # List of C routines that are driven by an M program elsewhere so they should not be invoked here
rm -f $drivenbyMlist
foreach file (gvnget*.c)
	echo ""
	echo " --> Running $file <---"
	cp $gtm_tst/$tst/inref/$file .
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "GVNGET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		exit -1
	endif
	./$exefile
end

$gtm_tst/com/dbcheck.csh
