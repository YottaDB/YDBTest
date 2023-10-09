#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that we get the appropriate error from a put that takes too many levels by using a massive spanning node with a tiny block size

# Precompute various parameters
source $gtm_tst/com/set_limits.csh
@ block_size = $MIN_BLOCK_SIZE
@ key_size = 472
@ record_size = $MAX_RECORD_SIZE
#
# The next to last term in the following expression ($block_size - 451) used to be ($block_size - 50) back in V6* versions
# as well as the V70000 version. When we merged V70001 into YottaDB, V70001 had a change to MAX_BT_DEPTH that went from 7
# to 11. This dramatically increased the number of global buffers needed to be able to get the expected MAXBTLEVEL error.
# So to increase the number of buffers, the block_size divisor value below was modified to generate far more buffers (was
# 4542 buffers but now it is 34396 buffers are needed to get the MAXBTLEVEL error. The value 451 was found through trial
# and error. A value of 450 (creating 33841 buffers) fails - getting the TRANS2BIG error instead.
#
@ global_buffer_count = 2 * ($record_size + $key_size) / ($block_size - 451) + 1
@ allocation = ((3 * $record_size) / 2) / $block_size
# Create the database with the above configuration
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size $allocation $global_buffer_count >&! db_create.out

$gtm_dist/mumps -direct << EOF
set ^a(\$justify(1,450))=\$translate(\$justify("",2**20-1)," ","*")
EOF
$gtm_tst/com/dbcheck.csh
