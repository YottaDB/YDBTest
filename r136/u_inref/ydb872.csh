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

echo "# Automated test case for test.csh/helper.csh in https://gitlab.com/YottaDB/DB/YDB/-/issues/872#description"

echo "# Create an empty M program tmp.m in current directory"
echo " " > tmp.m

echo "# Set gtmroutines env var to use auto-relink on current directory"
setenv gtmroutines ".*(.)"

echo "# Fire off 16 background jobs each of which start lots of short-lived YottaDB processes that in turn open/close relinkctl file"

@ cnt2 = 0
while ($cnt2 < 16)
	# Redirect output of helper script into .mjo file that way test framework will catch any errors (e.g. GTMASSERT2).
	(source $gtm_tst/$tst/u_inref/ydb872helper.csh >& ydb872helper.mjo$cnt2 & ; echo $! >&! ydb872helper.$cnt2.pid) >& ydb872helper.$cnt2.bg.out
        @ cnt2 = $cnt2 + 1
end

echo "# Wait for all background jobs to finish"
@ cnt2 = 0
while ($cnt2 < 16)
	set bgpid = `cat ydb872helper.$cnt2.pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
        @ cnt2 = $cnt2 + 1
end

echo "# Check for any errors (done by test framework). Should see no output below."
