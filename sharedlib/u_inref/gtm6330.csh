#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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
# GTM-6330: Reduce Process Memory Footprint - Literals
#

# Make sure gtm_test_dynamic_literals is having some effect via do_random_settings/submit_test. Useful for a quick manual verification.
echo "# Incoming gtmcompile environmental variable:"
if ($?gtmcompile) then
	echo $gtmcompile
else
	echo "gtmcompile: undefined"
endif

# Disable MPROF since it mallocs a bunch of 8k chunks, which distort our memory-use comparisons here.
unsetenv gtm_trace_gbl_name
echo "# gtm6330 test starts..."
$gtm_exe/mumps -run genlits^gtm6330 > lotlits_orig.txt

## 1. Compile, link shared library, and run without dynamic literals. Collect baseline memory usage.

source $gtm_tst/com/unset_ydb_env_var.csh ydb_compile gtmcompile
\cp lotlits_orig.txt lotlits.m
$gtm_exe/mumps lotlits.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix lotlits.o ${gt_ld_m_shl_options} >& link1_ld.outx

\rm lotlits.*
setenv gtmdbglvl 0x00008002
$GTM << EOF1 >&! run1.log
	Set \$zro="./shlib$gt_ld_shl_suffix"
	Do ^lotlits
	Halt
EOF1
unsetenv gtmdbglvl

## 2. Repeat, this time with dynamic literals. Make sure memory usage is reduced.

\rm shlib*
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-dynamic_literals"
\cp lotlits_orig.txt lotlits.m
$gtm_exe/mumps lotlits.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix lotlits.o ${gt_ld_m_shl_options} >& link2_ld.outx

\rm lotlits.*
setenv gtmdbglvl 0x00008002
$GTM << EOF2 >&! run2.log
	Set \$zro="./shlib$gt_ld_shl_suffix"
	Do ^lotlits
	Halt
EOF2
unsetenv gtmdbglvl

# See how much memory was used. Currently, should be no more than 15% of amount used in run 1.
$grep "Total (currently) allocated (includes overhead):" run1.log > run1_trim.log
$grep "Total (currently) allocated (includes overhead):" run2.log > run2_trim.log
$gtm_exe/mumps -run cmpmem^gtm6330

#################################################################
## 3. A few gtmcompile/$ZCOMPILE test cases

echo " Quit" > tmp.m

echo "# a) Expect good.o and tmp.lis to be generated"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_compile gtmcompile
\rm -rf tmp.o good.o notgood.o tmp.lis
$gtm_exe/mumps -list -object="good.o" tmp.m
\ls tmp.o good.o tmp.lis

echo "# b) Expect same as (a)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-list -object=""good.o"""
\rm -rf tmp.o good.o notgood.o tmp.lis
$gtm_exe/mumps tmp.m
\ls tmp.o good.o tmp.lis

echo "# c) Expect same as (a)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-list"
\rm -rf tmp.o good.o notgood.o tmp.lis
$gtm_exe/mumps -object="good.o" tmp.m
\ls tmp.o good.o tmp.lis

echo "# d) Expect same as (a)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-object=""good.o"""
\rm -rf tmp.o good.o notgood.o tmp.lis
$gtm_exe/mumps -list tmp.m
\ls tmp.o good.o tmp.lis

echo "# e) Expect MUMPS qualifiers to override gtmcompile. Expect good.o to be generated"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-list -object=""notgood.o"""
\rm -rf tmp.o good.o notgood.o tmp.lis
$gtm_exe/mumps -nolist -object="good.o" tmp.m
\ls tmp.o good.o notgood.o tmp.lis

echo "# f) ZCOMPILE variant of (a)"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_compile gtmcompile
\rm -rf tmp.o good.o notgood.o tmp.lis
$GTM << EOF >>&! zcomp.out
	ZCompile "-list -object=""good.o"" tmp.m"
	Halt
EOF
\ls tmp.o good.o tmp.lis

echo "# g) ZCOMPILE variant of (b)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-list -object=""good.o"""
\rm -rf tmp.o good.o notgood.o tmp.lis
$GTM << EOF >>&! zcomp.out
	ZCompile "tmp.m"
	Halt
EOF
\ls tmp.o good.o tmp.lis

echo "# h) ZCOMPILE variant of (c)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-list"
\rm -rf tmp.o good.o notgood.o tmp.lis
$GTM << EOF >>&! zcomp.out
	ZCompile "-object=""good.o"" tmp.m"
	Halt
EOF
\ls tmp.o good.o tmp.lis

echo "# i) ZCOMPILE variant of (d)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-object=""good.o"""
\rm -rf tmp.o good.o notgood.o tmp.lis
$GTM << EOF >>&! zcomp.out
	ZCompile "-list tmp.m"
	Halt
EOF
\ls tmp.o good.o tmp.lis

echo "# j) ZCOMPILE variant of (e)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_compile gtmcompile "-list -object=""notgood.o"""
\rm -rf tmp.o good.o notgood.o tmp.lis
$GTM << EOF >>&! zcomp.out
	ZCompile "-nolist -object=""good.o"" tmp.m"
	Halt
EOF
\ls tmp.o good.o notgood.o tmp.lis

echo "# gtm6330 test complete."
