#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Get the current limits
source $gtm_tst/com/set_limits.csh

set good_limits = 0

while (! $good_limits)
	# Set the random number of regions in the range [1; 5]
	@ RAND_REG_COUNT = `$gtm_dist/mumps -run rand 5 1 1`

	# Set the random maximum key size in the range [MIN_KEY_SIZE + 3; MAX_KEY_SIZE]
	@ MIN_RAND_KEY_SIZE = $MIN_KEY_SIZE + 3
	@ KEY_RANGE = $MAX_KEY_SIZE - $MIN_RAND_KEY_SIZE + 1
	@ RAND_KEY_SIZE = `$gtm_dist/mumps -run rand $KEY_RANGE 1 $MIN_RAND_KEY_SIZE`

	# Set the random maximum record size in the range [MIN_RECORD_SIZE + 5; MAX_RECORD_SIZE]
	@ MIN_RAND_RECORD_SIZE = $MIN_RECORD_SIZE + 5
	@ RECORD_RANGE = $MAX_RECORD_SIZE - $MIN_RAND_RECORD_SIZE + 1
	@ RAND_RECORD_SIZE = `$gtm_dist/mumps -run rand $RECORD_RANGE 1 $MIN_RAND_RECORD_SIZE`

	# Set the random maximum block size in the range [MIN(RAND_KEY_SIZE+BLOCK_HEADER_PADDING, MIN_BLOCK_SIZE); MAX_BLOCK_SIZE]
	if ($RAND_KEY_SIZE > $MIN_BLOCK_SIZE - $BLOCK_HEADER_PADDING) then
		@ MIN_RAND_BLOCK_SIZE = $RAND_KEY_SIZE + $BLOCK_HEADER_PADDING
	else
		@ MIN_RAND_BLOCK_SIZE = $MIN_BLOCK_SIZE
	endif
	@ BLOCK_RANGE = $MAX_BLOCK_SIZE - $MIN_RAND_BLOCK_SIZE + 1
	@ RAND_BLOCK_SIZE = `$gtm_dist/mumps -run rand $BLOCK_RANGE 1 $MIN_RAND_BLOCK_SIZE`
	# 512 is GT.M DISK_BLOCK_SIZE
	if ((0 != ($RAND_BLOCK_SIZE % 512))) then
		@ RAND_BLOCK_SIZE = (($RAND_BLOCK_SIZE + 512) / 512) * 512
	endif

	# Knowing the limitations on shared memory, also limit the record size to a value for whom the maximum allowable
	# global buffer count is enough (will be able to store two records of chosen size).
	@ MAX_RECORD_SPAN = ($RAND_RECORD_SIZE / (($RAND_BLOCK_SIZE - $BLOCK_HEADER_PADDING) - $RAND_KEY_SIZE))
	if ($MAX_RECORD_SPAN > 262080) continue

	# Try to pick the random global buffer count that would support three records of chosen size. If the estimated
	# shared memory requirements exceed 512MB, reevaluate the buffer count based on the block size and number of
	# regions in such a way that would ensure the 512MB limit.
	@ RAND_GLOBAL_BUFFER_COUNT = 3 * $MAX_RECORD_SPAN
	if ($RAND_GLOBAL_BUFFER_COUNT < 512) then
		@ RAND_GLOBAL_BUFFER_COUNT = 512
	endif
	@ APPROX_SHMEM_ALLOCATION = $RAND_GLOBAL_BUFFER_COUNT * $RAND_BLOCK_SIZE * $RAND_REG_COUNT
	if ($APPROX_SHMEM_ALLOCATION > 536870912) then
		@ RAND_GLOBAL_BUFFER_COUNT = 1638 * ($MAX_BLOCK_SIZE / $RAND_BLOCK_SIZE) * (5 / $RAND_REG_COUNT)
	endif
	if ($RAND_GLOBAL_BUFFER_COUNT > $MAX_GLOBAL_BUFFER_COUNT) then
		@ RAND_GLOBAL_BUFFER_COUNT = $MAX_GLOBAL_BUFFER_COUNT
	endif

	set good_limits = 1
end
