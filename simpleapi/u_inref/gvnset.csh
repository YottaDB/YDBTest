#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_set_s() function for Global variables in the simpleAPI
#
echo "Copy all C programs that need to be tested"
cp $gtm_tst/$tst/inref/gvnset*.c .

cat > gvnset.xc << CAT_EOF
gvnZWRITE: void ^gvnZWRITE()
CAT_EOF

setenv GTMCI gvnset.xc	# needed to invoke driveZWRITE.m from gvnset*.c below

foreach file (gvnset*.c)
	echo " --> Running $file <---"
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "GVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		continue
	endif
	# In the below dbcreate.csh call,
	#	more than default keysize needed for gvnset2_31subs.c
	#	null subscripts needed for gvnset3_errors.c
	$gtm_tst/com/dbcreate.csh mumps 1 -key_size=256 -null_subscripts=TRUE
	`pwd`/$exefile
	echo ""
	$gtm_tst/com/dbcheck.csh
	$gtm_tst/com/backup_dbjnl.csh bak_$exefile "*.dat *.mjl*" mv
end
