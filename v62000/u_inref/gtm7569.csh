#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
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
@ global_buffer_count = 2 * ($record_size + $key_size) / ($block_size - 50) + 1
@ allocation = ((3 * $record_size) / 2) / $block_size
# Create the database with the above configuration
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size $allocation $global_buffer_count >&! db_create.out

$gtm_dist/mumps -direct << EOF
set ^a(\$justify(1,450))=\$translate(\$justify("",2**20-1)," ","*")
EOF
$gtm_tst/com/dbcheck.csh
