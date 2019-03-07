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
# Test of ydb_node_previous_st() function for local and global variables in the SimpleThreadAPI.
# See nodeprevious.m for a description of how this test works.
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/nodepreviouscb.c
$gt_ld_shl_linker ${gt_ld_option_output}nodepreviouscb${gt_ld_shl_suffix} $gt_ld_shl_options nodepreviouscb.o $gt_ld_syslibs
#
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=4000 -key_size=1019 -glob=8192
#
setenv GTMXC nodepreviouscb.tab
echo "`pwd`/nodepreviouscb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
nodepreviouscb: void nodepreviouscb(I:ydb_string_t *)
xx

cat > nodeprevious.xc << CAT_EOF
drivelvnnodepreviouscb:	void lvn^nodeprevious()
drivegvnnodepreviouscb:	void gvn^nodeprevious()
CAT_EOF

setenv GTMCI nodeprevious.xc	# needed to invoke nodepreviouscb.m from nodeprevious*.c below

echo ""
echo "# Now run nodeprevious*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/nodeprevious*.c .
set drivenbyMlist = "nodepreviouscb.c" # List of C routines that are driven by an M program elsewhere so they should not be invoked here
rm -f $drivenbyMlist
foreach file (nodeprevious*.c)
	echo ""
	echo " --> Running $file <---"
	cp $gtm_tst/$tst/inref/$file .
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "LVNGET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		exit -1
	endif
	`pwd`/$exefile
	# Compare the two output files
	diff nodeprevioussublist_M.txt nodeprevioussublist_SAPI.txt
	if (0 != $status) then
	    echo "Test failed - The nodeprevioussublist_M.txt and nodeprevioussublist_SAPI.txt files differ for $file"
	    exit 1
	endif
	mv nodeprevioussublist_M.txt{,_$file}
	mv nodeprevioussublist_SAPI.txt{,_$file}
end
$gtm_tst/com/dbcheck.csh
