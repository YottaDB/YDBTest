#!/usr/local/bin/tcsh -f
source $gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run driver >& /dev/null
$gtm_tst/com/dbcheck.csh
grep -i "failed" d002016*.mj*
