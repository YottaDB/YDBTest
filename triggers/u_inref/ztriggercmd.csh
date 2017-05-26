#!/usr/local/bin/tcsh -f
$gtm_exe/mumps $gtm_tst/$tst/inref/inspectISV.m >&! knowncompfail.outx
$gtm_exe/mumps -run setup^ztriggercmd > sourceme.csh
source sourceme.csh
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run ztriggercmd
$gtm_tst/com/dbcheck.csh -extract
