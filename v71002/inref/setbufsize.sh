#!/usr/bin/bash
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

tnum=$1		# Test number
server=$2	# Target server, "ORIG" or "REPL"
buffer=$3	# Target buffer, "SNDBUF" or "RCVBUF"
min=$4		# Start of range
max=$5		# End of range
exp=$6		# Expected final value, if specified

if [[ $max -gt $min ]]; then
	bufval=$(( RANDOM % (max - min) + min ))
else
	bufval=$min
fi

outfile="$tnum-${server}_$buffer-exp"
if [[ 0 -eq $(echo -n $exp | wc -c) ]]; then
	echo $bufval &> $outfile.logx
elif [[ 0 -lt $(echo -n $exp | wc -c) ]]; then
	echo $exp &> $outfile.logx
else
	echo "ERROR: Expected value is $exp. Must be >= 0."  &> $outfile.errx
fi

echo -n $bufval
