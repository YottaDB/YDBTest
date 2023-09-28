#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# This test is for C9B12-001854 GTM increments curr_tn even jnl_file_open fails
# it sets the jnl file to read only and tries to write to the db.
# Current transaction field from dse d -f should not change.

echo "Begin jnl_set test..."
# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in DSE output
source $gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -reg $tst_jnl_str "*" >&! jnl_on.log
$grep "YDB-I-JNLSTATE" jnl_on.log
chmod 444 mumps.mjl
$DSE d -f

$GTM << EOF
s ^x=1
halt
EOF

$DSE d -f

echo "End jnl_set test."
$gtm_tst/com/dbcheck.csh
