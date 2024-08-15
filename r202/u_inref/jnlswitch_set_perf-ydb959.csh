#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "###########################################################################################################"
echo '# Test no dramatic loss of global SET performance during jnl file switch'
echo "###########################################################################################################"

echo '# This test is based on https://gitlab.com/YottaDB/DB/YDB/-/issues/959#description'
echo '# But this test case is trimmed down to take only 1/100th of the time of that test case'
echo '# And yet demonstrate the original issue'
echo '# This test verifies gvstats increase linearly with journal file switch'
echo '# Before YDB#959 code fix, the gvstats would explode 10x times or even more when closer to journal file switch'
echo '# See https://gitlab.com/YottaDB/DB/YDB/-/issues/959#note_2049535577 for the actual gvstats that are looked at'

# This test relies on before image journaling being enabled.
setenv gtm_test_jnl "SETJNL"				# Force journaling
source $gtm_tst/com/gtm_test_setbeforeimage.csh		# Force before image journaling

# We use an autoswitchlimit that is 1/100th of the default value (8386500) to ensure test completes quickly and yet
# exercises the buggy code path of YDB#959.
setenv tst_jnl_str "$tst_jnl_str,autoswitchlimit=83865"

echo "# Run [dbcreate.csh]"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "# Run [mumps -run ydb959] for 10 iterations."
echo "# This will check various gvstats that they increase linearly with each iteration."
echo "# Before YDB#959 code fixes, gvstats like DWT used to increase non-linearly (10x or more increase instead of 1x)"
echo "# in every 4th iteration. After the YDB#959 code fixes, all of them increase linearly all iterations."
@ cnt = 0
while ($cnt < 10)
	echo "# Run [mumps -run ydb959 $cnt]. Do gvstat verification too each iteration."
	$gtm_dist/mumps -run ydb959 $cnt
	@ cnt = $cnt + 1
end

echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh >>& dbcheck.out

