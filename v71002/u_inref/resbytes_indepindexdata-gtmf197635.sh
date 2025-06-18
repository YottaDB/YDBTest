#!/bin/bash
#################################################################
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

test_num=$1
utility=$2
block_size=$3
num_reserved_bytes=$4
num_index_reserved_bytes=$5
num_data_reserved_bytes=$6

if [[ "$num_reserved_bytes" == "omit" ]]; then
	reserved_bytes=""
	num_reserved_bytes=""
elif [[ "$num_reserved_bytes" =~ ^init.* ]]; then
	reserved_bytes=""
	num_reserved_bytes=$(echo -n $num_reserved_bytes | sed 's/init\([0-9]*\)/\1/')
else
	reserved_bytes=" -reserved_bytes=$num_reserved_bytes"
fi
if [[ "$num_index_reserved_bytes" == "omit" ]]; then
	index_reserved_bytes=""
	num_index_reserved_bytes=$num_reserved_bytes
	index_bytes_available=$(( $block_size - $num_reserved_bytes ))
else
	index_reserved_bytes="-index_reserved_bytes=$num_index_reserved_bytes"
	index_bytes_available=$(( $block_size - $num_index_reserved_bytes ))
fi
if [[ "$num_data_reserved_bytes" == "omit" ]]; then
	data_reserved_bytes=""
	num_data_reserved_bytes=$num_reserved_bytes
	data_bytes_available=$(( $block_size - $num_reserved_bytes ))
else
	data_reserved_bytes=" -data_reserved_bytes=$num_data_reserved_bytes"
	data_bytes_available=$(( $block_size - $num_data_reserved_bytes ))
fi

data_bytes_used=$(( $data_bytes_available + 16 ))	# Add 16 to push the number of bytes used passed the limit
index_bytes_used=$(( $index_bytes_available + 16 ))	# Add 16 to push the number of bytes used passed the limit

if [[ "$utility" == "mupip" ]]; then
	echo "# Run [mupip set $index_reserved_bytes$data_reserved_bytes$reserved_bytes -reg '*']"
	$gtm_dist/mupip set $index_reserved_bytes$data_reserved_bytes$reserved_bytes -reg '*'
else
	echo "# Run [dse change -fileheader $index_reserved_bytes$data_reserved_bytes$reserved_bytes]"
	$gtm_dist/dse change -fileheader $index_reserved_bytes$data_reserved_bytes$reserved_bytes
fi
echo "# Expect index_reserved_bytes=$num_index_reserved_bytes and data_reserved_bytes=$num_data_reserved_bytes"
$gtm_dist/mupip dumpfhead -reg '*' &> $test_num-$utility-mupipdump.out
$gtm_dist/dse dump -fileheader &> $test_num-$utility-dsedump.out
grep "reserved_bytes" $test_num-$utility-mupipdump.out
grep "Reserved Bytes" $test_num-$utility-dsedump.out
echo "# Populate the database with a data value ($data_bytes_used) that exceeds available data block size ($data_bytes_available):"
echo '# [mumps -run %XCMD '"'"'set ^x="a" for i=0:1:'"$data_bytes_used"' set ^x=^x_"b"'"']"
$gtm_dist/mumps -run %XCMD 'set ^x="a" '"for i=0:1:$data_bytes_used"' set ^x=^x_"b"'
echo "# Populate the database with a subscripted global variable to create index blocks that exceed the available index block size ($index_bytes_available):"
echo '# [mumps -run %XCMD '"'"'for i=1:1:5 for j=1:1:'"$index_bytes_used"' set ^y(i,j)=$j(i_j,25)'"']"
$gtm_dist/mumps -run %XCMD 'for i=1:1:5 for j=1:1:'"$index_bytes_used"' set ^y(i,j)=$j(i_j,25)'
echo "# Confirm that:"
echo "# 1. No data blocks are more than -block_size minus -data_reserve_bytes ($block_size - $num_data_reserved_bytes = $data_bytes_available ($(printf "0x%x" $data_bytes_available))):"
total_blocks=$($gtm_dist/dse dump -b=0 2>&1 | grep -E "Block *.*:.*X" | tr -cd "X" | wc -c)
$gtm_dist/mumps -run %XCMD 'set totblks='"$total_blocks"' for i=1:1:totblks write "dump -bl=",$$FUNC^%DH(i)," -h",!' | $gtm_dist/dse |& grep Level &> $test_num-$utility-blockcheck.out
fail_blocks=""
valid_blocks=""
num_blocks=$(grep "Level 0" $test_num-$utility-blockcheck.out | wc -l)
total_block_size=0
while IFS= read -r line; do
	block=$(echo $line | sed 's/Block \([0-9A-F]*\).*$/\1/g' | cut -f 2 -d " ")
	hex_size=$(echo $line | sed 's/.*Size \([0-9A-F]*\).*$/\1/g')
	size=$(( 16#$hex_size ))
	total_block_size=$(( total_block_size + size ))
	if [[ $size -gt $data_bytes_available ]]; then
		fail_blocks="$fail_blocks\nBlock $block: $size (0x$hex_size)"
	elif [[ $size -gt $(awk -vn=$data_bytes_available 'BEGIN{printf("%.0f\n",n*0.9)}') ]]; then
		valid_blocks="$valid_blocks\n        Block $block: $size (0x$hex_size)"
	fi
done <<< $(grep "Level 0" $test_num-$utility-blockcheck.out)
if [[ $fail_blocks = "" ]]; then
	echo -e "$valid_blocks" &> $test_num-$utility-data-over90.out
	echo "------> Data blocks > 90% of block size but still in bounds: $(cat $test_num-$utility-data-over90.out | wc -l )"
else
	echo "FAILED: Some data blocks outside block size limits ($data_bytes_available). See $test_num-$utility-data-failed.out for details."
	echo -e "$fail_blocks" &> $test_num-$utility-data-failed.out
fi
echo "# 2. No index blocks are more than -block_size minus -index_reserve_bytes ($block_size - $num_index_reserved_bytes = $index_bytes_available ($(printf "0x%x" $index_bytes_available))):"
fail_blocks=""
valid_blocks=""
num_blocks=$(grep -v "Level 0" $test_num-$utility-blockcheck.out | wc -l)
total_block_size=0
while IFS= read -r line; do
	block=$(echo $line | sed 's/Block \([0-9A-F]*\).*$/\1/g' | cut -f 2 -d " ")
	hex_size=$(echo $line | sed 's/.*Size \([0-9A-F]*\).*$/\1/g')
	size=$(( 16#$hex_size ))
	total_block_size=$(( total_block_size + size ))
	if [[ $size -gt $index_bytes_available ]]; then
		fail_blocks="$fail_blocks\nBlock $block: $size (0x$hex_size)"
	elif [[ $size -gt $(awk -vn=$index_bytes_available 'BEGIN{printf("%.0f\n",n*0.9)}') ]]; then
		valid_blocks="$valid_blocks\n        Block $block: $size (0x$hex_size)"
	fi
done <<< $(grep -v "Level 0" $test_num-$utility-blockcheck.out)
if [[ $fail_blocks = "" ]]; then
	echo -n "------> Index blocks > 90% of block size but still in bounds:"
	echo -e "$valid_blocks"
else
	echo "FAILED: Some index blocks outside block size limits ($index_bytes_available). See $test_num-$utility-index-failed.out for details."
	echo -e "$fail_blocks" &> $test_num-$utility-index-failed.out
fi
