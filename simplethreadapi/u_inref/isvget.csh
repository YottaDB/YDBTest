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
# Test of ydb_get_st() function for ISVs in the SimpleThreadAPI
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/isvgetcb.c
$gt_ld_shl_linker ${gt_ld_option_output}libisvgetcb${gt_ld_shl_suffix} $gt_ld_shl_options isvgetcb.o $gt_ld_syslibs
\rm isvgetcb.o
setenv	GTMXC	isvgetcb.tab
echo "`pwd`/libisvgetcb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
isvgetcb:	void	isvgetcb(I:ydb_string_t *, O:ydb_string_t *[4096])
xx
cat > isvget.xc << CAT_EOF
driveisvgetcb:	gtm_int_t* isvgetcb()
CAT_EOF

setenv GTMCI isvget.xc	# needed to invoke isvgetcb.m from isvget*.c below

# The "simpleapi" version of this test does a "$gtm_dist/mumps -run isvgetcb"
# But we cannot do that here because an M invocation would make the process a SimpleAPI user at process startup
# which would then make it impossible to later do SimpleThreadAPI calls (happening through an external call at the end
# of the M program) so invoke the C program as the base (isvget0_cb.c) and invoke the M program as a call-in (using ydb_ci_t).

# ------------------------------------------------------------------------
# Note: This is where all C routines are driven including isvget0_cb.c corresponding to the M program isvgetcb.m
# ------------------------------------------------------------------------
echo ""
echo "# Now run isvget*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/isvget*.c .
set drivenbyMlist = "isvgetcb.c" # List of C routines that are driven by an M program elsewhere so they should not be invoked here
rm -f $drivenbyMlist
foreach file (isvget*.c)
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
