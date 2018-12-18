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
# Test of ydb_node_next_st() function for local and global variables in the SimpleThreadAPI.
# See nodenext.m for a description of how this test works.
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/nodenextcb.c
$gt_ld_shl_linker ${gt_ld_option_output}nodenextcb${gt_ld_shl_suffix} $gt_ld_shl_options nodenextcb.o $gt_ld_syslibs
#
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=4000 -key_size=1019 -glob=8192
#
setenv GTMXC nodenextcb.tab
echo "`pwd`/nodenextcb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
nodenextcb: void nodenextcb(I:ydb_string_t *)
xx

cat > nodenext.xc << CAT_EOF
drivelvnnodenextcb:	void lvn^nodenext()
drivegvnnodenextcb:	void gvn^nodenext()
CAT_EOF

setenv GTMCI nodenext.xc	# needed to invoke nodenextcb.m from nodenext*.c below

echo ""
echo "# Now run nodenext*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/nodenext*.c .
set drivenbyMlist = "nodenextcb.c" # List of C routines that are driven by an M program elsewhere so they should not be invoked here
rm -f $drivenbyMlist
foreach file (nodenext*.c)
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
	diff nodenextsublist_M.txt nodenextsublist_SAPI.txt
	if (0 != $status) then
	    echo "Test failed - The nodenextsublist_M.txt and nodenextsublist_SAPI.txt files differ for $file"
	    exit 1
	endif
	mv nodenextsublist_M.txt{,_$file}
	mv nodenextsublist_SAPI.txt{,_$file}
end
$gtm_tst/com/dbcheck.csh
