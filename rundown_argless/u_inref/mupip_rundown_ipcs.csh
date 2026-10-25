#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# This test verifies which of the shared memory, the FTOK semaphore and the access control semaphore of a crashed journaled
# database a MUPIP RUNDOWN command, argumentless or not, with no -OVERRIDE qualifier, leaves behind. This is accomplished by
# enforcing different testing options (such as whether shared memory is removed or MUPIP command has arguments) and verifying
# that the expectations are met. Below is a table containing all possible configurations and outcomes associated with them.
#
# - Cases 1 to 8 keep the shared memory, so MUPIP RUNDOWN declines to run the database down (MUUSERECOV). It leaves the shared
#   memory and both semaphores, except a semaphore that the case removed itself. It leaves the FTOK semaphore because, with
#   shared memory present, it cannot know whether the FTOK counter semaphore has halted, so on that error path it does not
#   delete the FTOK semaphore, as live processes could still be using it (see "counter_ftok_incremented" in
#   sr_unix/mu_rndwn_file.c).
# - Cases 9 to 16 remove the shared memory, so MUPIP RUNDOWN removes both semaphores.
# - An IPC that a case removes itself before MUPIP RUNDOWN is expected to be gone afterwards.

# ---------------------------------------------------------------------------------------------------------------------------------------------------------
#   Case			1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
set shared_memory_kept =      (	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0 )
set ftok_semaphore_kept =     (	1	1	1	1	0	0	0	0	1	1	1	1	0	0	0	0 )
set access_semaphore_kept =   (	1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	0 )
set mupip_rundown_args =      (	1	0	1	0	1	0	1	0	0	1	0	1	0	1	0	1 )
set expect_shm_gone =         (	0	0	0	0	0	0	0	0	1	1	1	1	1	1	1	1 )
set expect_ftok_sem_gone =    (	0	0	0	0	1	1	1	1	1	1	1	1	1	1	1	1 )
set expect_access_sem_gone =  (	0	0	1	1	0	0	1	1	1	1	1	1	1	1	1	1 )
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
