#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "This test verifies that call-in tables support blank lines and comments. If it succeeds, it will print out a success message."

# Setup call-in table

setenv ydb_ci `pwd`/tab.ci
cat >> tab.ci << xx
// This tests that comments and blank lines work in call-in tables.

tst:		ydb_int_t *	tst^tst() // this prints out a success message
//tst2:		ydb_int_t *	tst2^tst()
xx
cat >> tst.m << xxx
tst
	write "Call-In Test Succeeded",!
	quit 0
tst2
	write "This should not be printed",!
	quit 0
xxx

# Compile and link ydb566.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb566.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb566 $gt_ld_options_common ydb566.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
`pwd`/ydb566

echo "----------------------------------------------------"
echo "This part of the test verifies that external call definitions support blank lines and comments."
echo "If the first external call succeeds, it will print out a success message."
echo "This test will also test a commented out external call mapping. This should return an M error message"

# Compile ydb566B.c and make it a .so file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb566B.c
$gt_ld_shl_linker ${gt_ld_option_output}libydb566B${gt_ld_shl_suffix} $gt_ld_shl_options ydb566B.o $gt_ld_syslibs

#set up the xcall environment
setenv ydb_xc ydb566.tab
setenv GTMXC ydb566.tab
setenv  my_shlib_path `pwd`
echo '$my_shlib_path'"/libydb566B${gt_ld_shl_suffix}" > $ydb_xc
cat >> $ydb_xc << xx
// This tests that comments and blank lines work in external calls

printSuccess: void print_success() // This verifies that comments work at the end of a line
//printFailure: void print_failure()
xx
cat >> ydb566M.m << xxx
	do &printSuccess()
	do &printFailure()
xxx

# Call the M code
$ydb_dist/mumps -run ^ydb566M
