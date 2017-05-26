#!/usr/local/bin/tcsh -f
### Following is for computing speed test reference speed from ^run number of runs
unsetenv test_replic
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP load speed.glo
$GTM << xyz
do ^compute($test_speed_runs)
h
xyz
$gtm_tst/com/dbcheck.csh
