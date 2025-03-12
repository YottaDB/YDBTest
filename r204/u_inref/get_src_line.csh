#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# Test that -embed_source works even with very large source files'

set iters = `shuf -n1 -i 2000-5000`
echo "# Create a large source file"
foreach i (`seq 1 $iters`)
	echo ' set x=$text(+'"$i)" >> m$iters.m
end
$gtm_dist/mumps -embed_source m$iters.m

set lineno  = `shuf -n1 -i 1-$iters`
echo "# Verify a random line has the contents we expect"
set line = `$gtm_dist/mumps -run %XCMD 'write $text(+'"$lineno^m$iters),!"`
set expected = 'set x=$text(+'"$lineno)"
if ( "$line" != "$expected" ) then
	echo "TEST-E-FAIL: expected $expected, found $line"
endif
