#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1 255 1024 2048
$gtm_exe/mumps -run nodztrigintrig >&! nodztrigintrig.outx
# grep for failures but ignore STACKCRIT and ETRAP errors
$grep 'GTM-' nodztrigintrig.outx | $grep -vE 'STACKCRIT|ERRWETRAP'
echo Passing `$grep -c PASS nodztrigintrig.outx`
echo Failing `$grep -c FAIL nodztrigintrig.outx`
$gtm_tst/com/dbcheck.csh -extract
