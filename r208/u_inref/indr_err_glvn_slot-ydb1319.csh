#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#-------------------------------------------------------------------------------------------------#"
echo "# [YDB#1319] A glvn pool slot left unfilled by an error while an indirect reference is saved does #"
echo "# not crash the process when the glvn pool later needs more space for subscripts                  #"
echo "#-------------------------------------------------------------------------------------------------#"
echo
echo '# SET @ref=..., $ORDER(@ref,-1) and MERGE @ref=... reserve a slot in the glvn pool, then evaluate the'
echo '# indirect reference and its subscripts, and only then fill in the slot. An error in between leaves the'
echo '# slot reserved but unfilled, and the rest of a slot that was never used before holds whatever the memory'
echo '# allocator returned. When the glvn pool later needs more space for subscripts, it adjusts the pointers'
echo '# in every reserved slot, and it took the number of pointers in the unfilled slot from that memory.'
echo '#'
echo '# Each stage raises DIVZERO while it evaluates an indirect reference to a(1/z) with z=0. Its $ETRAP'
echo '# handler, which runs before the frame of the failed reference ends, then sets three indirect references'
echo '# with many subscripts in one SET, which needs more space than the 64 subscripts the glvn pool starts with.'
echo '#'
echo '# To make the memory hold a large count, the stages use the system memory allocator (gtmdbglvl=0x80000000)'
echo '# and have glibc fill new allocations with 0x55 bytes (MALLOC_PERTURB_=170). MERGE @ref=... uses the glvn'
echo '# pool only when side effects are evaluated left to right, so the stages also set gtm_side_effects=1.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1319.m .

# The test system sets gtmdbglvl and gtm_side_effects at random. Use the settings this subtest needs.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_dbglvl gtmdbglvl
source $gtm_tst/com/unset_ydb_env_var.csh ydb_side_effects gtm_side_effects
setenv gtmdbglvl 0x80000000
setenv MALLOC_PERTURB_ 170
setenv gtm_side_effects 1
echo '# Command : setenv gtmdbglvl 0x80000000'
echo '# Command : setenv MALLOC_PERTURB_ 170'
echo '# Command : setenv gtm_side_effects 1'
echo
echo '# Stage 1 : the example in YDB#1319:'
echo '#   ZNOOP  set z=0,$etrap="do h" set @"a(1/z)"=1'
echo '#   h      set s="1" for i=2:1:22 set s=s_",1"'
echo '#          set (@("x("_s_")"),@("y("_s_")"),@("w("_s_")"))=1'
echo '# Command : $gtm_dist/mumps -run znoop^ydb1319'
echo '# Before the fix, a Release build was killed by a SIG-11 in glvn_pool_expand_mvals(), so a KILLBYSIGSINFO1'
echo '# error was printed in place of the PASS line below, and a Debug build failed an assert in glvn_pool.c'
$gtm_dist/mumps -run znoop^ydb1319
echo

echo '# Stages 2 to 4 are variations of stage 1: the error is in SET @ref=1, $ORDER(@ref,-1) or MERGE @ref=b'
echo '# with ref="a(1/z)", and the $ETRAP handler sets three indirect references with 30 subscripts each'
echo

set stage = 1
foreach label (setind ordind mrgind)
	@ stage++
	switch ($label)
	case "setind":
		echo "# Stage $stage : SET @ref=1"
		breaksw
	case "ordind":
		echo "# Stage $stage : "'$ORDER(@ref,-1)'
		breaksw
	case "mrgind":
		echo "# Stage $stage : MERGE @ref=b"
		breaksw
	endsw
	echo "# Command : "'$gtm_dist/mumps -run '"${label}^ydb1319"
	echo '# Before the fix, a Release build was killed by a SIG-11 in glvn_pool_expand_mvals(), so a KILLBYSIGSINFO1'
	echo '# error was printed in place of the PASS line below, and a Debug build failed an assert in glvn_pool.c'
	$gtm_dist/mumps -run ${label}^ydb1319
	echo
end

echo '# Stage 5 : stage 1 with default memory allocator settings, after writing 65000 "U" characters, which'
echo '# are 0x55 bytes, to a file and closing it, which frees its output buffer. The glvn pool can get that'
echo '# memory, so the count in its never-used slot is large without MALLOC_PERTURB_.'
unsetenv MALLOC_PERTURB_
source $gtm_tst/com/unset_ydb_env_var.csh ydb_dbglvl gtmdbglvl
echo '# Command : unsetenv MALLOC_PERTURB_ gtmdbglvl'
echo '# Command : $gtm_dist/mumps -run zpre^ydb1319'
echo '# Before the fix, in some runs, a SIG-11, or in a Debug build an assert failure in glvn_pool.c, in place'
echo '# of the PASS line below, and in other runs the same PASS line, since whether the glvn pool gets that'
echo '# memory depends on the build and the environment of the run'
$gtm_dist/mumps -run zpre^ydb1319
echo

echo "# Done"
