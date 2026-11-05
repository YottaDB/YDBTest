#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
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

echo '### Test 1: $ZMAXTPTIME keeps millisecond precision'
echo '## SET $ZMAXTPTIME'
$gtm_dist/mumps -run setprec^gtm10603
echo '## Set gtm_zmaxtptime or ydb_maxtptime before process startup'
foreach val (".001" ".333" "59.999")
	echo "# Set the environment variable to ${val}. Expect ${val}. Previously, whole seconds only."
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_maxtptime gtm_zmaxtptime $val
	$gtm_dist/mumps -run show^gtm10603
end
echo

echo '### Test 2: $ZMAXTPTIME ignores values outside 0 to 60 seconds'
echo '## SET $ZMAXTPTIME'
$gtm_dist/mumps -run setlimit^gtm10603
echo '## Set gtm_zmaxtptime or ydb_maxtptime before process startup'
foreach val ("61" "60.001" "60")
	if ("60" == $val) then
		set expect = "60"
	else
		set expect = "0, the default"
	endif
	echo "# Set the environment variable to ${val}. Expect ${expect}."
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_maxtptime gtm_zmaxtptime $val
	$gtm_dist/mumps -run show^gtm10603
end
unsetenv ydb_maxtptime gtm_zmaxtptime
echo

echo '### Test 3: A fractional $ZMAXTPTIME times out a transaction'
echo '# SET $ZMAXTPTIME=.5 and hang for .1 seconds. Expect the transaction to commit.'
$gtm_dist/mumps -run timing^gtm10603 .5 .1
echo '# SET $ZMAXTPTIME=.5 and hang for 2 seconds. Expect a TPTIMEOUT error. Previously, the .5 was dropped,'
echo '# which left no timeout, so the transaction committed.'
$gtm_dist/mumps -run timing^gtm10603 .5 2

$gtm_tst/com/dbcheck.csh >& dbcheck.out
