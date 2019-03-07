#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Helper script to compile gtm8926.c and integrate it into the subtest
set file="gtm8926.c"
set exefile=$file:r
echo "# Compiling/Linking $file into executable $exefile"
cp $gtm_tst/$tst/inref/$file .
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file
$gt_ld_shl_linker ${gt_ld_option_output}$exefile${gt_ld_shl_suffix} $gt_ld_shl_options $exefile.o $gt_ld_syslibs

if (0 != $status) then
	echo "GTM8926-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif

# gtm8926.m will also create a .o file, so rm the one we just created
rm $exefile.o

setenv GTMXC gtm8926.tab
echo "`pwd`/gtm8926.so" > $GTMXC
cat >> $GTMXC << EOF
callout: void callout()
EOF
