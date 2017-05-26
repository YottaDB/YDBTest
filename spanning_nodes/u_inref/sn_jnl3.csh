#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################
# Create a database with five regions; turn on journaling on four of them (all except         #
# default). In the non-journaled region write four globals: one that fits within a block, one #
# that spans two blocks, one that spans ten blocks, and the final one of maximum record size. #
# Then copy these globals into the journaled regions, a global per region. Overwrite the      #
# globals in the journaled regions with empty values and try to recover them afterwards to    #
# their original values. Verify that the restored values correspond to those in the           #
# non-journaled region.                                                                       #
###############################################################################################
echo "Verify that non-spanning globals, global that span a few blocks, and globals that span a lot of blocks can be all journaled and properly restored from journal files."
echo

# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
# Get the current limits
source $gtm_tst/com/set_limits.csh

# Precompute various parameters
@ key_size = 8
@ record_size = $MAX_RECORD_SIZE
@ block_size = 1024
@ allocation = ((3 * $record_size) / 2) / $block_size
@ global_buffer_count = 2 * ($MAX_RECORD_SIZE / ($block_size - 50) + 1)

# Create the database with the above configuration
$gtm_tst/com/dbcreate.csh mumps 5 $key_size $record_size $block_size $allocation $global_buffer_count >&! db_create.out

# Enable before-image journaling on regions A, B, C, and D
$gtm_dist/mupip set -journal=enable,on,before -reg "AREG,BREG,CREG,DREG" >&! mupip_set.out

# Set the size of a global to almost fully occupy one block
@ two_block_global_size = (3 * $block_size) / 2
@ ten_block_global_size = ($block_size - 50) * 10
@ max_record_global_size = $record_size

# Generate four globals---one that does not span, one that spans two blocks, one that spans ten blocks, and
# the final one of the maximum record size. Make sure the values have been stored properly. Then copy the
# stored values to the journaled regions and write the date and time to be later used in 'before' clause of
# the recovery. Finally overwrite the values of the globals.
$gtm_dist/mumps -direct << EOF >&! mumps.out
write "a global of length $two_block_global_size should span 2 blocks",!
write "a global of length $ten_block_global_size should span 10 blocks",!
write "a global of length $max_record_global_size should span a lot of blocks",!
hang 2
set ^z1="abcdefghijklmnopqrstuvwxyz"
set ^z2=\$justify("abcdefghijklmnopqrstuvwxyz",$two_block_global_size)
set ^z3=\$justify("abcdefghijklmnopqrstuvwxyz",$ten_block_global_size)
set ^z4=\$justify("abcdefghijklmnopqrstuvwxyz",$max_record_global_size)
hang 2
if ^z1'="abcdefghijklmnopqrstuvwxyz" write "TEST-E-FAIL value of ^def1 saved incorrectly"
if ^z2'=\$justify("abcdefghijklmnopqrstuvwxyz",$two_block_global_size) write "TEST-E-FAIL value of ^def2 saved incorrectly"
if ^z3'=\$justify("abcdefghijklmnopqrstuvwxyz",$ten_block_global_size) write "TEST-E-FAIL value of ^def3 saved incorrectly"
if ^z4'=\$justify("abcdefghijklmnopqrstuvwxyz",$max_record_global_size) write "TEST-E-FAIL value of ^def3 saved incorrectly"
set ^a=^z1
set ^b=^z2
set ^c=^z3
set ^d=^z4
hang 2
write "before "_\$zdate(\$horolog,"DD-MON-YEAR 24:60:SS"),!
hang 2
set ^a="zyxwvutsrqponmlkjihgfedcba"
set ^b="zyxwvutsrqponmlkjihgfedcba"
set ^c="zyxwvutsrqponmlkjihgfedcba"
set ^d="zyxwvutsrqponmlkjihgfedcba"
EOF

# Find the the time of the first epoch in the A region's journal extract
$gtm_dist/mupip journal -extract -noverify -detail -for -fences=none a.mjl >&! mupip_jnl_extract.out
$head a.mjf | $grep EPOCH | $tst_awk -F "\\" '{print $2}' >&! since.txt
set since = `cat since.txt`
$gtm_dist/mumps -direct << EOF >&! since.txt
write \$zdate("$since","DD-MON-YEAR 24:60:SS")
EOF

# Prepare the since and before values for the recovery
set since = `$grep "^[0-9]" since.txt`
set before = `$grep before mumps.out | $tst_awk '{print $2" "$3}'`

# Recover the four journaled regions using the since and before times
$gtm_dist/mupip journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" a.mjl >&! mupip_jnl_rec_a.log
$gtm_dist/mupip journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" b.mjl >&! mupip_jnl_rec_b.log
$gtm_dist/mupip journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" c.mjl >&! mupip_jnl_rec_c.log
$gtm_dist/mupip journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" d.mjl >&! mupip_jnl_rec_d.log

# Verify that the original values have been restored as the result of recovery
$gtm_dist/mumps -direct << EOF >&! mumps2.out
if ^a'=^z1 write "TEST-E-FAIL ^a has a different value",!
if ^b'=^z2 write "TEST-E-FAIL ^b has a different value",!
if ^c'=^z3 write "TEST-E-FAIL ^c has a different value",!
if ^d'=^z4 write "TEST-E-FAIL ^d has a different value",!
EOF

# Verify that the database is OK
$gtm_tst/com/dbcheck.csh
