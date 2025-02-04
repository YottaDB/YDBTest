#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1 255 1024 2048
$gtm_exe/mumps -run dztriggerintp > dztriggerintp.outx
echo Passing `$grep -c PASS dztriggerintp.outx`
echo Failing `$grep -c FAIL dztriggerintp.outx`
$gtm_exe/mumps -run onlydztrigintxn
$gtm_tst/com/dbcheck.csh -extract
