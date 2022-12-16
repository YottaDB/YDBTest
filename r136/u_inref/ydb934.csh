#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo '########################################################################################################'
echo '# Test that error in $ZTIMEOUT vector does NOT cause infinite loop in direct mode.'
echo '# The below test case has a LVUNDEF error inside the $ZTIMEOUT M code.'
echo '# Before YDB@44ccc849, this test case used to assert fail in Debug builds and produce infinite LVUNDEF messages.'
echo '########################################################################################################'

echo ''
echo '# Try test in direct mode [yottadb -direct]'
echo '# We expect to see 2 sets of a LVUNDEF message followed by a ERRWZTIMEOUT message.'
# Filter out comment lines from ydb934.m as they clutter the reference file output otherwise
grep -v ';' $gtm_tst/$tst/inref/ydb934.m | $ydb_dist/yottadb -direct

echo ''
echo '# Try test in [yottadb -run] mode'
echo '# We expect to see 2 LVUNDEF messages (no ERRWZTIMEOUT message).'
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^ydb934'

