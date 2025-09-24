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
GTM-10603 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410603)

\$ZMAXTPTIME and its initializing environment variable, \$gtm_zmaxtptime, maintain precision to milliseconds (three digits after the decimal point). Also, both ignore values exceeding a maximum of 60 seconds. Previously \$ZMAXTPTIME only provided whole seconds, and, while it limited the initial value to 60 seconds, it did not limit the SET value. (GTM-10603)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "### Test 1: Test a variety of sub-second timeout values"
foreach timeout ("0.001" "0.002" "0.003" "0.011" "0.022" "0.033" "0.111" "0.222" "0.333")
	# Test transaction runtimes both over and under the timeout by adding or subtracting from it in the test routine
	foreach setting ("var" "env")
		if ("var" == $setting) then
			echo '## Test $ZMAXTPTIME='"$timeout"
			foreach modifier ("minus" "plus")
				$gtm_dist/mumps -r gtm10603 $timeout $modifier "0.001"
			end
		else
			echo '## Test gtm_maxtptime='"$timeout"
			foreach modifier ("minus" "plus")
				setenv gtm_zmaxtptime $timeout
				$gtm_dist/mumps -r gtm10603 "env" $modifier "0.001"
			end
		endif
		echo
	end
end

echo '### Test 2: Test $ZMAXTPTIME values > 60 seconds are ignored'
unsetenv gtm_zmaxtptime $timeout
$gtm_dist/mumps -r gtm10603 61 "plus" 1

$gtm_tst/com/dbcheck.csh >& dbcheck.out
