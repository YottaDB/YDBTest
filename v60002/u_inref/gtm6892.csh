#!/usr/local/bin/tcsh -f
# Test that fsync latch is released in case of error return from fsync in jnl_fsync

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 88
setenv gtm_white_box_test_case_count 5

setenv gtm_test_jnl "SETJNL"
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -flush=3000 -file mumps.dat	# Set a large-enough flush timer so wcs_wtstart is NOT invoked to do intermediate fsync

$gtm_exe/mumps -run manytp |& tee manytp.outx |& sed 's/I\/O error/##FILTERED##/g' |& sed 's/Input\/output error/##FILTERED##/g'

$gtm_tst/com/dbcheck.csh
