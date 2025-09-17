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
GTM-9833 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE197637833)

\$STORAGE reports the correct value when there is a restriction on the data segment limit (RLIMIT_DATA) of a process. Previously, \$STORAGE inappropriately returned 2GiB in such a case. (GTM-9833)

CAT_EOF
echo

echo '# Test that $STORAGE returns the correct value, based on the current RLIMIT_DATA (data segment size) limit.'
echo '# Running  [$gtm_dist/mumps -r %XCMD '"'write "'$STORAGE,!'"'] consumes about 680kB"
echo '# of memory. So, $STORAGE should return the specified RLIMIT_DATA limit minus about 680kB.'

set base = 696320	# 680kB == 680 * 1024
set sizes = "2048 4096 16384 32768 65536 131072"
set i = 1
foreach size ($sizes)
	echo
	echo "# Case ${i}: Set process data segment size (RLIMIT_DATA) to $size"
	limit datasize $size
	@ kBsize = $size * 1024
	@ expected = $kBsize - $base
	set high = `echo "scale=2; $expected * 1.05" | bc | cut -d '.' -f 1`
	set low = `echo "scale=2; $expected * 0.95" | bc | cut -d '.' -f 1`
	echo '# Run [$gtm_dist/mumps -r %XCMD '"'write "'$STORAGE,!'"']"
	echo '# Expect $STORAGE to be between '"$high and $low"
	set storage = `$gtm_dist/mumps -r %XCMD 'write $STORAGE'`
	if (($storage <= $high) && ($storage >= $low)) then
		echo 'PASS: $STORAGE='"$storage"
	else
		echo 'FAIL: $STORAGE='"$storage"
	endif
	@ i = $i + 1
end
