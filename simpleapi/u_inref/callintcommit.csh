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
echo "# Test of CALLINTCOMMIT error"
#

echo "Copy all C programs that need to be tested"
cp $gtm_tst/$tst/inref/callintcommit*.c .

cat > callintcommit.xc << CAT_EOF
callintcommit: void ^callintcom()
CAT_EOF

setenv GTMCI callintcommit.xc	# needed to invoke driveZWRITE.m

$gtm_tst/com/dbcreate.csh mumps 1

foreach file (callintcommit*.c)
	echo " --> Running $file <---"
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "TIME2LONG-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		continue
	endif
	`pwd`/$exefile
	echo ""
end

$gtm_tst/com/dbcheck.csh
