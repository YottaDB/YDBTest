#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9F11-002578 MUPIP SET -FLUSH=xxx does not work
#

setenv gtm_test_spanreg	0	# Test requires traditional global mappings, so disable spanning regions
echo "# subtest override"		>> settings.csh
echo "setenv gtm_test_spanreg 0"	>> settings.csh

$gtm_tst/com/dbcreate.csh mumps 4

# Start GT.M process in background that updates BREG and DEFAULT (but not AREG and CREG)
$GTM << GTM_EOF
	do startjob^d002578
	quit
GTM_EOF

set verbose
$MUPIP set -flush=00:02:00 -file a.dat	# should work
$MUPIP set -flush=00:03:00 -reg  BREG	# should work
$MUPIP set -flush=00:04:00 -reg  CREG	# should work
$MUPIP set -flush=00:05:00 -file mumps.dat -glo=1024 >& glo_err.outx # should error out since -glo doesn't have standalone access
unset verbose

$grep -qE 'mumps.dat.*(File is in use|File already open) by another process' glo_err.outx
if ($status) then
	echo "FLUSH-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in glo_err.outx"
endif
$grep -v 'GTM-W-WCWRNNOTCHG' glo_err.outx >& glo_err.out
$gtm_tst/com/get_dse_df.csh        # creates dse_df.log
$grep -E "Region          |Flush timer" dse_df.log
mv dse_df.log dse_df1.log

echo ""
set verbose
$MUPIP set -flush=00:07:00 -reg "*"	# should work fine
unset verbose
$gtm_tst/com/get_dse_df.csh        # creates dse_df.log
$grep -E "Region          |Flush timer" dse_df.log
mv dse_df.log dse_df2.log

# End GT.M process
$GTM << GTM_EOF
	do waitjob^d002578
	quit
GTM_EOF

$gtm_tst/com/dbcheck.csh
