#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test ensures that shared memory as well as FTOK and access control semaphores are not left behind after a MUPIP RUNDOWN
# command, argumentless or not, with no -OVERRIDE qualifier. This is accomplished by enforcing different testing options (such
# as whether shared memory is removed or MUPIP command has arguments) and verifying that the expectations are met. Below is a
# table containing all possible configurations and outcomes associated with them.

# ---------------------------------------------------------------------------------------------------------------------------------------------------------
#   Case			1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
set shared_memory_kept =      (	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0 )
set ftok_semaphore_kept =     (	1	1	1	1	0	0	0	0	1	1	1	1	0	0	0	0 )
set access_semaphore_kept =   (	1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	0 )
set mupip_rundown_args =      (	1	0	1	0	1	0	1	0	0	1	0	1	0	1	0	1 )
set expect_shm_gone =         (	0	0	0	0	0	0	0	0	1	1	1	1	1	1	1	1 )
set expect_ftok_sem_gone =    (	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1 )
set expect_access_sem_gone =  (	0	0	0	0	0	0	0	0	1	1	1	1	1	1	1	1 )
set expect_mupip_error =      (	1	1	1	1	1	1	1	1	0	1	0	1	0	1	0	1 )
# ---------------------------------------------------------------------------------------------------------------------------------------------------------

@ num_of_cases = $#shared_memory_kept
@ case = 0

set all_fine = 1

while ($case < $num_of_cases)
	@ case = $case + 1

	# Invoke the helper routine with selected options.
	$gtm_tst/$tst/u_inref/mupip_rundown_ipcs_helper.csh	\
		$case						\
		$shared_memory_kept[$case]			\
		$ftok_semaphore_kept[$case]			\
		$access_semaphore_kept[$case]			\
		$mupip_rundown_args[$case]			\
		$expect_shm_gone[$case]				\
		$expect_ftok_sem_gone[$case]			\
		$expect_access_sem_gone[$case]			\
		$expect_mupip_error[$case] >&! mupip_rundown_ipcs${case}.logx

	$grep -q "TEST-E-FAIL" mupip_rundown_ipcs${case}.logx
	if (! $status) then
		echo "TEST-E-FAIL, Test case $case failed. See mupip_rundown_ipcs${case}.logx for details."
		echo
		set all_fine = 0
	endif
end

if ($all_fine) then
	echo "TEST-I-SUCCESS, All test cases passed."
endif
