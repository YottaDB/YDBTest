#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

# Tests that when a single operation exceeds both STACKCRIT and STACKOFLOW that
# GTM no longer segfaults but instead exits with a STACKOFLOW error.
# Related tests: v63004/gtm1042 which also fills up the M stack

setenv ydb_msgprefix "GTM"   # So can run the test under GTM or YDB

# set minimum thresholds
setenv gtm_mstack_size 25  # KiB
setenv gtm_mstack_crit_threshold 15  # percentage of gtm_mstack_size

echo "# Several attempts to produce STACKCRIT and STACKOVER error in one hit"
echo "# Should produce STACKOVER error and should not segfault like it does in GTM versions"
echo

# Now we'll create an M file that seems to confuse GT.M
echo >! test.m "test"
echo >> test.m " quit"   # merely proves that the crash is not caused by actually running the crash function
echo >> test.m "crash"
set i=1000
echo >> test.m " set a$i=1"
foreach j (`seq 1000 500 4000`)
	echo "# Running M with a function that sets variable names a1000-a$j"
	while ($i < $j)
		@ i += 1
		echo >> test.m " set a$i=1"
	end
	$ydb_dist/mumps -run test
	if ( $status == 0 ) echo "Good: exit code 0"
	# This test's outref only catches segfaults. Stack errors are expected.
	# However, the exact stack error varies by YDB version, so both are allowed
end

# Rename the expected coredump and GTM_FATAL_ERROR files, so that YDBTest's error catcher misses them
# Use `find` to avoid cshell's "No match" error if no such files exist
foreach file ( `find -maxdepth 1 -name "core*" -o -name "YDB_FATAL*" -o -name "GTM_FATAL*"` )
	mv $file $file:s/core/dump/:s/YDB_//:s/GTM_//
end
