#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
# temporarily claim to be xcalls $tst since we are reusing those components
setenv tst xcall
$gtm_exe/mumps $gtm_tst/$tst/inref/mathtst.m
source $gtm_tst/$tst/u_inref/make_math.csh
setenv tst triggers
$gtm_exe/mumps -run trigxcalls
$gtm_tst/com/dbcheck.csh -extract
