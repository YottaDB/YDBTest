#!/usr/local/bin/tcsh -f
# This test is for C9B12-001854 GTM increments curr_tn even jnl_file_open fails
# it sets the jnl file to read only and tries to write to the db.
# Current transaction field from dse d -f should not change.

echo "Begin jnl_set test..."
# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
source $gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -reg $tst_jnl_str "*" >&! jnl_on.log
$grep "GTM-I-JNLSTATE" jnl_on.log
chmod 444 mumps.mjl
$DSE d -f

$GTM << EOF
s ^x=1
halt
EOF

$DSE d -f

echo "End jnl_set test."
$gtm_tst/com/dbcheck.csh
