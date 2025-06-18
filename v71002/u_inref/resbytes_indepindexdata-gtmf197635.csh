#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F197635- Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-F197635)

The -INDEX_RESERVED_BYTES and -DATA_RESERVED_BYTES qualifiers for MUPIPSET (and DSE CHANGE -FHEAD) allow independent adjustment of reserved bytes for each block type. Previously GT.M did not provide the flexibility to set these values independently. The -RESERVED_BYTES qualifier continues to adjust both types of block to the same value. When the command specifies -RESERVED_BYTES along one of the more specific qualifiers, MUPIP applies the more general -RESERVED_BYTES value to the block type unspecified by the other qualifier. MUPIP DUMPFHEAD reports the number of bytes reserved for each type of block (as does DSE DUMP -FHEAD). Reserving additional bytes in index blocks can reduce the number of records in any given index block and may reduce invalidation and search restarts in some workloads. (GTM-F197635)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
# Disable V6 DBs since they result in slightly different block sizes and index_reserved_bytes values, e.g. the following failed test diff:
# Diff of resbytes_indepindexdata-gtmf197635 follows
# 271,274c271,274
# < Rec:1  Blk 4  Off 10  Size 14  Cmpc 0  Ptr 3  Key ^x(#SPAN1*)
# < Rec:2  Blk 4  Off 24  Size 10  Cmpc 4  Ptr 7  Key ^x(#SPAN2*)
# < Rec:3  Blk 4  Off 34  Size 10  Cmpc 4  Ptr A  Key ^x(#SPAN3*)
# < Rec:4  Blk 4  Off 44  Size 10  Cmpc 4  Ptr B  Key ^x(#SPAN4*)
# ---
# > Rec:1  Blk 4  Off 10  Size 10  Cmpc 0  Ptr 3  Key ^x(#SPAN1*)
# > Rec:2  Blk 4  Off 20  Size C  Cmpc 4  Ptr 7  Key ^x(#SPAN2*)
# > Rec:3  Blk 4  Off 2C  Size C  Cmpc 4  Ptr A  Key ^x(#SPAN3*)
# > Rec:4  Blk 4  Off 38  Size C  Cmpc 4  Ptr B  Key ^x(#SPAN4*)
# 286c286
# < %YDB-W-MUPIPSET2BIG, 256 too large, maximum INDEX_RESERVED_BYTES allowed is 216
# ---
# > %YDB-W-MUPIPSET2BIG, 256 too large, maximum INDEX_RESERVED_BYTES allowed is 224
setenv gtm_test_use_V6_DBs 0

set block_size = 2048
set bytesA = 512
set bytesB = 1024

echo "### Test 1: -INDEX_RESERVED_BYTES and -DATA_RESERVED_BYTES can be set independently"
set test_num = "T1"
set num_reserved_bytes = "omit"
set num_index_reserved_bytes = $bytesA
set num_data_reserved_bytes = $bytesB
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "## Test with MUPIP: Run [resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo "# Cleanup global variables before changing any reserved bytes qualifiers with DSE"
$gtm_dist/mumps -run %XCMD 'kill ^x,^y'
set num_index_reserved_bytes = $bytesB
set num_data_reserved_bytes = $bytesA
echo "## Test with DSE: Run [resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo

echo "### Test 2: When -DATA_RESERVED_BYTES is omitted, it is set to -RESERVED_BYTES when -RESERVED_BYTES and -INDEX_RESERVED_BYTES are set"
set test_num = "T2"
set num_reserved_bytes = $bytesB
set num_index_reserved_bytes = $bytesA
set num_data_reserved_bytes = "omit"
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "## Test with MUPIP: Run [resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo "# Cleanup global variables before changing any reserved bytes qualifiers with DSE"
$gtm_dist/mumps -run %XCMD 'kill ^x,^y'
set num_reserved_bytes = $bytesA
set num_index_reserved_bytes = $bytesB
echo "## Test with DSE: Run [resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo

echo "### Test 3: When -INDEX_RESERVED_BYTES is omitted, it is set to -RESERVED_BYTES when -RESERVED_BYTES and -DATA_RESERVED_BYTES are set"
set test_num = "T3"
set num_reserved_bytes = $bytesB
set num_index_reserved_bytes = "omit"
set num_data_reserved_bytes = $bytesA
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "## Test with MUPIP: Run [resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo "# Cleanup global variables before changing any reserved bytes qualifiers with DSE"
$gtm_dist/mumps -run %XCMD 'kill ^x,^y'
set num_reserved_bytes = $bytesA
set num_data_reserved_bytes = $bytesB
echo "## Test with DSE: Run [resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo

echo "### Test 4: -INDEX_RESERVED_BYTES and -DATA_RESERVED_BYTES are set to -RESERVED_BYTES when only -RESERVED_BYTES is specified"
set test_num = "T4"
set num_reserved_bytes = $bytesA
set num_index_reserved_bytes = "omit"
set num_data_reserved_bytes = "omit"
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "## Test with MUPIP: Run [resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo "# Cleanup global variables before changing any reserved bytes qualifiers with DSE"
$gtm_dist/mumps -run %XCMD 'kill ^x,^y'
set num_reserved_bytes = $bytesB
echo "## Test with DSE: Run [resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo

echo "### Test 5: Setting -INDEX_RESERVED_BYTES and omitting both -DATA_RESERVED_BYTES and -RESERVED_BYTES leaves -DATA_RESERVED_BYTES unchanged"
set test_num = "T5"
set num_reserved_bytes = "init$bytesA"
set num_index_reserved_bytes = $bytesB
set num_data_reserved_bytes = "omit"
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "# Run [mupip set -reserved_bytes=$bytesA -reg '*'] to initialize -data_reserved_bytes and -index_reserved_bytes"
$gtm_dist/mupip set -reserved_bytes=$bytesA -reg '*'
echo "# Expect index_reserved_bytes=$bytesA and data_reserved_bytes=$bytesA"
$gtm_dist/mupip dumpfhead -reg '*' >&! $test_num-init-mupipdumpA.out
$gtm_dist/dse dump -fileheader >&! $test_num-init-dsedumpA.out
grep "reserved_bytes" $test_num-init-mupipdumpA.out
grep "Reserved Bytes" $test_num-init-dsedumpA.out
echo "## Test with MUPIP: Run [resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo "# Cleanup global variables before changing any reserved bytes qualifiers with DSE"
$gtm_dist/mumps -run %XCMD 'kill ^x,^y'
set num_reserved_bytes = "init$bytesB"
set num_index_reserved_bytes = $bytesA
echo "# Run [mupip set -reserved_bytes=$bytesB -reg '*'] to initialize -data_reserved_bytes and -index_reserved_bytes"
$gtm_dist/mupip set -reserved_bytes=$bytesB -reg '*'
echo "# Expect index_reserved_bytes=$bytesB and data_reserved_bytes=$bytesB"
$gtm_dist/mupip dumpfhead -reg '*' >&! $test_num-init-mupipdumpB.out
$gtm_dist/dse dump -fileheader >&! $test_num-init-dsedumpB.out
grep "reserved_bytes" $test_num-init-mupipdumpB.out
grep "Reserved Bytes" $test_num-init-dsedumpB.out
echo "## Test with DSE: Run [resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo

echo "### Test 6: Setting -DATA_RESERVED_BYTES and omitting both -INDEX_RESERVED_BYTES and -RESERVED_BYTES leaves -INDEX_RESERVED_BYTES unchanged"
set test_num = "T6"
set num_reserved_bytes = "init$bytesA"
set num_index_reserved_bytes = "omit"
set num_data_reserved_bytes = $bytesB
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "# Run [mupip set -reserved_bytes=$bytesA -reg '*'] to initialize -data_reserved_bytes and -index_reserved_bytes"
$gtm_dist/mupip set -reserved_bytes=$bytesA -reg '*'
echo "# Expect index_reserved_bytes=$bytesA and data_reserved_bytes=$bytesA"
$gtm_dist/mupip dumpfhead -reg '*' >&! $test_num-init-mupipdumpA.out
$gtm_dist/dse dump -fileheader >&! $test_num-init-dsedumpA.out
grep "reserved_bytes" $test_num-init-mupipdumpA.out
grep "Reserved Bytes" $test_num-init-dsedumpA.out
echo "## Test with MUPIP: Run [resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num mupip $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo "# Cleanup global variables before changing any reserved bytes qualifiers with DSE"
$gtm_dist/mumps -run %XCMD 'kill ^x,^y'
set num_reserved_bytes = "init$bytesB"
set num_data_reserved_bytes = $bytesA
echo "# Run [mupip set -reserved_bytes=$bytesB -reg '*'] to initialize -data_reserved_bytes and -index_reserved_bytes"
$gtm_dist/mupip set -reserved_bytes=$bytesB -reg '*'
echo "# Expect index_reserved_bytes=$bytesB and data_reserved_bytes=$bytesB"
$gtm_dist/mupip dumpfhead -reg '*' >&! $test_num-init-mupipdumpB.out
$gtm_dist/dse dump -fileheader >&! $test_num-init-dsedumpB.out
grep "reserved_bytes" $test_num-init-mupipdumpB.out
grep "Reserved Bytes" $test_num-init-dsedumpB.out
echo "## Test with DSE: Run [resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes]"
$gtm_tst/$tst/u_inref/resbytes_indepindexdata-gtmf197635.sh $test_num dse $block_size $num_reserved_bytes $num_index_reserved_bytes $num_data_reserved_bytes
echo

echo "### Test 7: Setting a GVN to a value greater than a database block can hold causes a block split and creates spanning nodes"
set test_num = "T7"
set num_data_reserved_bytes = 1556
@ data_bytes_available = $block_size - $num_data_reserved_bytes
@ data_bytes_used = $block_size - $data_bytes_available
echo "# Create a database"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size >& dbcreate$test_num.out
echo "# Reserve a lot of bytes ($num_data_reserved_bytes) relative to block size ($block_size) to decrease available block space and make it easier to cause a block split:"
echo "# Run [mupip set -data_reserved_bytes=$num_data_reserved_bytes -reg '*']"
$gtm_dist/mupip set -data_reserved_bytes=$num_data_reserved_bytes -reg '*'
echo "# Expect data_reserved_bytes=$num_data_reserved_bytes"
$gtm_dist/mupip dumpfhead -reg '*' >&! $test_num-init-mupipdumpA.out
$gtm_dist/dse dump -fileheader >&! $test_num-init-dsedumpA.out
grep "reserved_bytes" $test_num-init-mupipdumpA.out
grep "Reserved Bytes" $test_num-init-dsedumpA.out
echo "# Populate the database with a data value ($data_bytes_used) that exceeds available data block size ($data_bytes_available):"
echo '# [mumps -run %XCMD '"'"'set ^x="a" for i=0:1:'"$data_bytes_used"' set ^x=^x_"b"'"']"
$gtm_dist/mumps -run %XCMD 'set ^x="a" '"for i=0:1:$data_bytes_used"' set ^x=^x_"b"'
echo "## Confirm that the block was split and spanning nodes were generated"
echo "# Get the block containing the target key (^x):"
echo '# Run [($gtm_dist/dse find -key=^x >&! /dev/stdout) | tail -1 | cut -f 1 -d ":" | tr -d "\t"]'
set key_block = `($gtm_dist/dse find -key=^x >&! /dev/stdout) | tail -1 | cut -f 1 -d ":" | tr -d "\t"`
echo '# Dump that block and confirm that #SPAN records were created'
($gtm_dist/dse dump -b=$key_block >&! /dev/stdout) | grep SPAN
echo

echo "### Test 8: Test that it is not possible create an index block that is larger than available database block space"
echo "## Scenario A: MUPIPSET2BIG"
echo "## To create an index block that exceeds the database block size it is necessary to"
echo "## store a key that exceeds the space available after subtracting the number of index reserved bytes"
echo "## from the total block size. However, it is not possible to set index_reserved_bytes to more than"
echo "## the block_size - max_key_size - 40 (block overhead). Attempting to do so results in a MUPIPSET2BIG error."
set test_num = "T8"
set block_size = 1024
set key_size = 492
set block_overhead = 40
@ max_index_reserved_bytes = $block_size - $key_size - $block_overhead
@ num_index_reserved_bytes = $max_index_reserved_bytes + 1
echo "# Create a database with: -block_size=$block_size -record_size=$block_size -key_size=$key_size"
setenv gtmgbldir $test_num.gld
$gtm_tst/com/dbcreate.csh $test_num -block_size=$block_size -record_size=$block_size -key_size=$key_size >& dbcreate$test_num.out
echo "# Attempt to reserve more index bytes ($num_index_reserved_bytes) than available ($max_index_reserved_bytes), i.e. (block_size - key_size - block overhead)=($block_size - $key_size - $block_overhead)"
echo "# Run [mupip set -index_reserved_bytes=$num_index_reserved_bytes -reg '*']"
echo "# Expect MUPIPSET2BIG"
$gtm_dist/mupip set -index_reserved_bytes=$num_index_reserved_bytes -reg '*'
echo "## Scenario B: Index block split"
echo "# Populate multiple GVNs in the database with using subscripts with lengths close to the value of -index_reserved_bytes"
echo "# to create more records than can fit in a single index block, thus causing a split of the records across multiple index blocks."
echo "# This operation should succeed, with each split block having a size less than the block_size - index_reserved_bytes."
set num_index_reserved_bytes = 450
set subscript_length = 400
@ max_index_bytes = $block_size - $num_index_reserved_bytes
echo "# Run [mupip set -index_reserved_bytes=$num_index_reserved_bytes -reg '*']"
$gtm_dist/mupip set -index_reserved_bytes=$num_index_reserved_bytes -reg '*'
echo "# Expect index_reserved_bytes=$num_index_reserved_bytes"
$gtm_dist/mupip dumpfhead -reg '*' >&! $test_num-init-mupipdumpA.out
$gtm_dist/dse dump -fileheader >&! $test_num-init-dsedumpA.out
grep "reserved_bytes" $test_num-init-mupipdumpA.out
grep "Reserved Bytes" $test_num-init-dsedumpA.out
echo "# Populate the database with subscripted global variable nodes to create index blocks that exceed the max index reserved bytes size ($subscript_length):"
echo '# [mumps -run %XCMD '"'"'for i=1:1:5 for j=1:1:'"$subscript_length"' set ^y($j(i,'"$subscript_length"'),j)=$j(i_j,25)'"']"
$gtm_dist/mumps -run %XCMD 'for i=1:1:5 for j=1:1:'"$subscript_length"' set ^y($j(i,'"$subscript_length"'),j)=$j(i_j,25)'
echo "# Dump the headers for the index blocks created by the above M command and confirm that the size of none exceed the maximum number of index bytes available (block_size - num_index_reserved_bytes) ($block_size - $num_index_reserved_bytes = $max_index_bytes = `printf "0x%x" $max_index_bytes`)"
set total_blocks = `$gtm_dist/dse dump -b=0 |& grep -E "Block *.*:.*X" | tr -cd "X" | wc -c`
$gtm_dist/mumps -run %XCMD 'set totblks='"$total_blocks"' for i=1:1:totblks write "dump -bl=",$$FUNC^%DH(i)," -h",!' | $gtm_dist/dse |& grep Level | grep -v 'Level 0'

$gtm_tst/com/dbcheck.csh >& dbcheck.out
