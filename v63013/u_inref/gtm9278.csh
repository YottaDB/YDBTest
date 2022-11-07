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

echo '# Test for GTM-9278'
echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
#
# The first of this test needs the white box test setup so can only run in dbg mode
#
if ("dbg" == $tst_image) then
    echo
    echo '# Setup WBTEST_YDB_MAXSECSHRRETRY white box test'
    setenv gtm_white_box_test_case_enable 1
    setenv gtm_white_box_test_case_number 205	# WBTEST_YDB_MAXSECSHRRETRY
    echo
    echo '# Changing our database to read-only (priv 0444) and running lke on the DB. Since it is R/O, it will'
    echo '# attempt to engage gtmsecshr which will fail and drive the error code we want to test.'
    chmod 444 mumps.dat
    echo
    echo '# Now try to invoke LKE. The messages that follow should include a message that the DB header flush'
    echo '# failed followed by a GTMSECSHRTMPPATH message.'
    $gtm_dist/lke show all
    echo
    echo '# Removing R/O state from DB and unset white box case envvars'
    chmod 664 mumps.dat
    unsetenv gtm_white_box_test_case_enable
    unsetenv gtm_white_box_test_case_number
endif
echo
echo '# Change the global directory to point to a directory (dirnotdat.dat) in the test and create the'
echo '# directory. Then run LKE on it.'
$gtm_dist/yottadb -run GDE change -segment DEFAULT -file=dirnotdat.dat
mkdir dirnotdat.dat
$gtm_dist/lke show all
echo '# Now try to invoke MUPIP integ -file (i.e. a command that requires standalone access to the database).'
$gtm_dist/mupip integ -file dirnotdat.dat
echo
#
# The original version of this test was getting left-over ftok semaphores causing failures most of the time
# but not ALL the time. To fix this, YDB#927 was created and fixed and became a prereq for this test. The
# initial version of the YDB#927 fix had problems when it was run (in this situation with the "database"
# actually being a directory) so below we run 6 simultaneous processes running the same test. It initially
# failed with just 2 so this really thrashes it good.
#
echo
echo '# Run YDB#927 exerciser 6 times. Failures marked by the presence of core files. Each instance of the'
echo '# exerciser runs a simplistic routine 100 times so with 6 instances, there is lots of interference'
echo '# between the processes. With the database name being set to a directory name, this causes errors on'
echo '# every attempted DB open and this test makes sure everything is cleaned up correctly without errors.'
cat >> ydb927a.csh << EOF
@ cnt = 0
while (\$cnt < 1000)
        @ cnt = \$cnt + 1
        echo " --> Iteration \$cnt <-- "
        \$gtm_dist/mumps -run ydb927
        echo ""
end
EOF
cat >> ydb927.m << EOF
	set \$etrap="write \$zstatus,!"
	set x=^x
EOF
#
# We do not let the framework scan these logs as they are intentionally full of errors. The core files and
# FATAL_ERROR* files that are generated suffice to discover if the assert failures recur. Send each concurrent
# process output to its own output file to prevent cross-threading of output if all were to write to the same
# output file.
#
cat >> ydb927.csh << EOF
@ cnt = 0
while (\$cnt < 6)
    @ cnt = \$cnt + 1
    source ydb927a.csh >& ydb927a-run-\${cnt}.logx&
end
wait 		# Wait for background tasks above to finish
EOF
#
# Invoke script so all of its semi-randomized subprocess starts and exits are not written to the reference file
#
tcsh ydb927.csh >& ydb927.log
echo
echo '# Run a filter on the YDB#927 output logs to remove the expected errors. The framework will verify that'
echo '# no unexpected errors occurred. The filter creates .log version of the input .logx file sans the expected'
echo '# DBFILOPERR/ENO21 error combination errors.'
@ cnt = 0
while ($cnt < 6)
    @ cnt = $cnt + 1
    $gtm_dist/mumps -run filter^gtm9278 "ydb927a-run-${cnt}.logx"
end
echo
echo '# Set DB back to how it was so it can be integ''d'
$gtm_dist/yottadb -run GDE change -segment DEFAULT -file=mumps.dat
echo
echo "# Verify database we (very lightly) used"
$gtm_tst/com/dbcheck.csh
