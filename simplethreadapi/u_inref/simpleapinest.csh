#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	#
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

cp $gtm_tst/$tst/inref/simpleapinest* .

$gtm_tst/com/dbcreate.csh mumps 1 >> create.txt
if ($status != 0) then
	echo "dbcreate failed:"
	cat create.txt
endif

cat > simpleapinest.trg << CAT_EOF
+^basevar -commands=Set,Kill -xecute="do ^simpleapinestm"
CAT_EOF

$gtm_exe/mupip trigger -noprompt -trigger=simpleapinest.trg

cat > simpleapinestm.m << CAT_EOF
simpleapinest	;
	write "In trigger M code. This in turn will invoke an external call",!
	do &callouthelp
	quit
simpleapinestci ;
	write "In ci M code level: "_\$increment(^count)_". This in turn will invoke an external call",!
	do &calloutci
	quit
CAT_EOF

setenv GTMXC `pwd`/libsimpleapinest.xc

cat > libsimpleapinest.xc << CAT_EOF
`pwd`/libsimpleapinest.so
callouthelp: int simpleapinest_helper()
calloutci: int simpleapinest_ci()
CAT_EOF

setenv GTMCI `pwd`/libsimpleapinest.ci

cat > libsimpleapinest.ci << CAT_EOF
simpleapinestci: void simpleapinestci^simpleapinestm()
CAT_EOF


# Compile simpleapinest_helper.c
set file = simpleapinest_helper.c
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist -g $file
$gt_cc_compiler ${gt_ld_shl_options} ${gt_ld_option_output} libsimpleapinest.so $exefile.o

set file = "simpleapinest.c"
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

$gtm_tst/com/dbcheck.csh >> dbcheck.txt
if ($status != 0) then
	echo "Check failed:"
	cat dbcheck.txt
endif
