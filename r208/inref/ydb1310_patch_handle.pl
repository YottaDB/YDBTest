#!/usr/bin/perl
#################################################################
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
# Usage: perl ydb1310_patch_handle.pl <binary extract file> <handle index>
#
# Overwrites the encryption handle index of the first data block in an encrypted MUPIP EXTRACT -FORMAT=BINARY file.
# Every record in the file is a 2-byte little-endian length followed by that many bytes. The records of each global
# start with a 4-byte collation header record, and in an encrypted extract every data block record that follows
# starts with the 4-byte handle index. So the first record after the first 4-byte record holds the index to patch.
use strict;
use warnings;

my ($file, $index) = @ARGV;
open(my $fh, '+<:raw', $file) or die "Cannot open $file: $!\n";
my $data = do { local $/; <$fh> };
my ($pos, $prevlen) = (0, -1);
while ($pos + 2 <= length($data))
{
	my $len = unpack('v', substr($data, $pos, 2));
	if (4 == $prevlen)
	{
		seek($fh, $pos + 2, 0) or die "Cannot seek in $file: $!\n";
		print $fh pack('l<', $index);
		close($fh) or die "Cannot close $file: $!\n";
		print "Patched the encryption handle index of the first data block to $index\n";
		exit 0;
	}
	$prevlen = $len;
	$pos += 2 + $len;
}
die "No data block record found after a collation header record in $file\n";
