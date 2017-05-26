#!/usr/local/bin/tcsh -f
# The test checks for actual vs. formal list parameters works correctly for Longnames
# The M-routine called will set values to variables & call more sub-routines to check
# various parameter combinations.
#
cp $gtm_tst/$tst/inref/paramchk.m .
$GTM << gtm_eof
do ^paramchk
halt
gtm_eof
#
# This section is separated out, as we expect GTM to throw error here.
$GTM << gtm_err
do error^paramchk
do error1^paramchk
do error2^paramchk
halt
gtm_err
