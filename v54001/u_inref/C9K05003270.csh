#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that GT.M correctly handles cases where the snapshot file is not accessible (for e.g, snapshot file is in a directory
# where the current user does not have read access) and MUPIP INTEG reports "Permission denied" error in such cases rendering
# the snapshot not relialable (as one would expect).
setenv gtm_test_mupip_set_version "disable"	# ONLINE INTEG is supported only on V5 databases
setenv gtm_test_jobcnt 1
setenv gtm_test_dbfill "IMPTP"

$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -allocation=2048 -extension_count=2048

echo ""
echo ""
$echoline
echo "Start few mumps processes"
$echoline
echo ""
echo ""
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 60	# Give some time for the mumps process to warm up

set syslog_before = `date +"%b %e %H:%M:%S"`

$echoline
echo "Using gtmtest1 as the other user, set gtm_snaptmpdir such that, it is accessible only by gtmtest1 and not by the current user"
echo "With this setup, start ONLINE INTEG as gtmtest1 user."
$echoline
echo ""
echo ""
$gtm_tst/$tst/u_inref/user2.csh >&! user2.log

$echoline
set regssfail_cnt = `$grep "REGSSFAIL" remote_user.log | wc -l`
if (0 != "$regssfail_cnt") then
	echo "REGSSFAIL error seen during ONLINE INTEG run as expected"
else
	echo "TEST-E-FAILED: REGSSFAIL error not seen after 10 runs of MUPIP INTEG"
endif
$echoline
echo ""
echo ""

$gtm_tst/com/endtp.csh >>&! imptp.out

$echoline
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog.txt "" "SSFILOPERR"
set ssfiloperr_cnt = `$grep "SSFILOPERR" syslog.txt  | wc -l`
if (! $ssfiloperr_cnt || (10 < $ssfiloperr_cnt )) then
	# We should see only one SSFILOPERR in syslog per failed INTEG. Since, not all INTEGs are guaranteed to fail, check if the
	# number of SSFILOPERR error messages is zero or greater than 10. If so, indicate that the test failed.
	echo "TEST-E-FAILED : Either no SSFILOPERR seen or more than 10 occurrences found. Please check syslog.txt"
else
	echo "SSFILOPERR errors seen during ONLINE INTEG run as expected"
endif
$echoline
echo ""

# remote_user.log could contain a bunch of INTEG errors which could change with each run and hence not deterministically
# captured with check_error_exist script. All these errors are expected owing due to the failed snapshot. Filter them all.
$gtm_tst/com/knownerror.csh remote_user.log "INTEGERRS|REGSSFAIL"

$gtm_tst/com/dbcheck.csh		# Final INTEG should come out clean
