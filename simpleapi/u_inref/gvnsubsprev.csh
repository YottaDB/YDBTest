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
# Test of ydb_subscript_prev_s() function for Global variables in the simpleAPI
#

cat > gvnsubsprev.xc << CAT_EOF
gvnZWRITE: void ^gvnZWRITE()
CAT_EOF

setenv GTMCI gvnsubsprev.xc	# needed to invoke gvnZWRITE.m from gvnsubsprev*.c below
echo ""
echo "# Now run gvnsubsprev*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/gvnsubsprev*.c .
foreach file (gvnsubsprev*.c)
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
	# In the below dbcreate.csh call,
	#	more than default keysize needed for gvnsubsprev2_31subs.c
	#	null subscripts needed for gvnsubsprev3_errors.c
	$gtm_tst/com/dbcreate.csh mumps 1 -key_size=256 -null_subscripts=TRUE
	./$exefile
	$gtm_tst/com/dbcheck.csh
	$gtm_tst/com/backup_dbjnl.csh bak_$exefile "*.dat *.mjl*" mv
end
