#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a test of correct ZBREAK behavior with autorelink. It works by invoking a script that creates a large number
# of M sources along with the expected outputs from their executions. We then invoke them sequentially and make sure
# that our expectations are met.

# We do not want autorelink-enabled directories that have been randomly assigned by the test system because we are explicitly
# testing the autorelink functionality, as opposed to the rest of the test system which may be testing it implicitly.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# Prepare the individual scripts and reference files.
$gtm_dist/mumps -run zbreak

# Prepare the requisite source files and shared libraries.
cd dir
foreach rtn (orig copy)
	cp rtn.m.$rtn rtn.m
	$gtm_dist/mumps rtn.m
	${gt_ld_m_shl_linker} ${gt_ld_option_output} librtn.${rtn}${gt_ld_shl_suffix} rtn.o ${gt_ld_m_shl_options}
	rm rtn.o
end
cd ..

# Execute the M files in a loop.
@ count = `cat test_count`
@ i = 1
@ failed = 0
while ($i <= $count)
	cp dir/rtn.m.orig dir/rtn.m
	$gtm_dist/mumps -run test${i} >&! test${i}.out
	diff test${i}.cmp test${i}.out
	# If we get a failure, report it and save the objects.
	if ($status) then
		echo "TEST-E-FAIL, Case $i failed. Relevant files have been moved to case${i}."
		echo
		echo "Expected:"
		cat test${i}.cmp
		echo
		echo "Got:"
		cat test${i}.out
		echo
		echo "Code:"
		cat test${i}.m
		echo
		echo
		@ failed = 1
		mkdir case${i}
		cp -pr dir case${i}
		cp -p test${i}.{m,out,cmp} case${i}
	endif

	rm dir/*.o >&! /dev/null
	@ i++
end

if (0 == $failed) then
	echo "TEST-I-SUCCESS, Test successful."
endif
