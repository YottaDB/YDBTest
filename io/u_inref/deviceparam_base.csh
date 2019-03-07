#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
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

# Test various deviceparameters (for sequential files).
# Note that there might be other tests that are testing some of the deviceparameters (that will not be
# tested here), i.e. this is not a complete test on it's own.

# increase gtm_non_blocked_write_retries so fifo test will still pass with non-blocking writes
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_non_blocked_write_retries gtm_non_blocked_write_retries 300

$switch_chset M >&! /dev/null
set echoline = "echo =================================================================================="

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

$echoline
echo "# APPEND - Test that APPEND deviceparameter appends to the end of the file"
$GTM << EOF
do ^append
halt
EOF

$echoline
echo "# DELETE  - Test that the DELETE deviceparameter for CLOSE actually deletes the file."
$GTM << EOF
do ^delete
halt
EOF

$echoline
echo "# Test fixed length reads"
$GTM << EOF
do ^fixedlen
halt
EOF

$echoline
echo "# RENAME - Test that the RENAME deviceparameter for CLOSE actually renames the file."
$GTM << EOF
do ^rename
halt
EOF

$echoline
echo "# REWIND -test that REWIND does rewind to the beginning of the file"
$GTM << EOF
do ^rewind
halt
EOF

$echoline
echo "# READONLY - Test that a device that was opened READONLY cannot be written into."
$GTM << EOF
do ^readonly
halt
EOF

$echoline
echo "# TRUNCATE - Test that TRUNCATE deviceparameter works for OPEN and USE."
$GTM << EOF
do ^truncate
halt
EOF

$echoline
echo "# FIXED - test that FIXED records work as expected."
$GTM << EOF
do ^fixed
halt
EOF

$echoline
echo "# RECORDSIZE and WIDTH"
$GTM << EOF
do ^recwid
halt
EOF

$echoline
echo "# LENGTH"
$GTM << EOF
do ^length
halt
EOF

$echoline
# there is a comprehensive fifo test in basic
echo "# FIFO - RECORDSIZE and WIDTH limits for FIFO devices"
$GTM << EOF
do ^fifo
halt
EOF

set jobid = `$tst_awk '/fifo2 jobid:/ {print $3}' fifo2_fifo.mjo1`
$gtm_tst/com/wait_for_proc_to_die.csh $jobid
$GTM << EOF
do ^shrnkfil("fifo2_fifo.mjo1","fifo_short.mjo")
halt
EOF
$tst_awk 'BEGIN {p=0} { if (/message:/) {p=1} ; if (p==1) {print}}' fifo_short.mjo
# let's not do error checking on fifo.mjo (since it will be done one fifo_short.mjo):
mv fifo2_fifo.mjo1 fifo2_fifo_mjo.dontcheck

$echoline
echo "# DESTROY - Test that the DESTROY deviceparameter for CLOSE destroy the sequential disk file device."
$GTM << EOF
do ^destroy
halt
EOF

$echoline
echo "# DESTROY - Test that the DESTROY deviceparameter for CLOSE destroy the FIFO and PIPE device."
$GTM << EOF
do ^destroyfifopipe
halt
EOF

$gtm_tst/com/dbcheck.csh
