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
echo "# Test of SIMPLEAPINEST error"
#

$gtm_tst/com/dbcreate.csh mumps 1

cat > simpleapinest.trg << CAT_EOF
+^basevar -commands=Set,Kill -xecute="do ^simpleapinestm"
CAT_EOF

$gtm_exe/mupip trigger -noprompt -trigger=simpleapinest.trg

cat > simpleapinestm.m << CAT_EOF
simpleapinest	;
	write "In trigger M code. This in turn will invoke an external call",!
	do &callout
	quit
CAT_EOF

setenv GTMXC `pwd`/libsimpleapinest.xc

cat > libsimpleapinest.xc << CAT_EOF
`pwd`/libsimpleapinest.so
callout: int simpleapinest_helper()
CAT_EOF

# Compile simpleapinest_helper.c
set file = simpleapinest_helper.c
cp $gtm_tst/$tst/inref/$file .
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist -g $file
$gt_cc_compiler ${gt_ld_shl_options} ${gt_ld_option_output} libsimpleapinest.so $exefile.o

set file = "simpleapinest.c"
cp $gtm_tst/$tst/inref/$file .
echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "SIMPLEAPINEST-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	continue
endif
rm $exefile.o
`pwd`/$exefile
echo ""

$gtm_tst/com/dbcheck.csh
