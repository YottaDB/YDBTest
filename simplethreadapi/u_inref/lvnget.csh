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
# Test of ydb_get_st() function for Local variables in the SimpleThreadAPI
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour
echo "# Run lvngetcb.m first since it is driven by an M routine"
echo " --> Running lvngetcb.m <--"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/lvngetcb.c
$gt_ld_shl_linker ${gt_ld_option_output}liblvngetcb${gt_ld_shl_suffix} $gt_ld_shl_options lvngetcb.o $gt_ld_syslibs
\rm lvngetcb.o
setenv	GTMXC	lvngetcb.tab
echo "`pwd`/liblvngetcb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
lvngetcb:		void	lvngetcb()
xx
$gtm_dist/mumps -run lvngetcb

cat > lvnget.xc << CAT_EOF
driveZWRITE: void driveZWRITE(I:ydb_string_t *)
CAT_EOF

setenv GTMCI lvnget.xc	# needed to invoke driveZWRITE.m from lvnget*.c below

echo ""
echo "# Now run lvnget*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/lvnget*.c .
set drivenbyMlist = "lvngetcb.c" # List of C routines that are driven by an M program elsewhere so they should not be invoked here
rm -f $drivenbyMlist
foreach file (lvnget*.c)
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
end
