#!/usr/local/bin/tcsh -f
# This test loads the triggers defined in basic.trg and sees if the tasks are executed properly.

setenv gtm_test_trigger 1
#dbcreate
$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=4000
$gtm_exe/mupip create
cp $gtm_tst/$tst/inref/basic.trg basic.trg
$gtm_tst/com/trigger_load.csh basic.trg ""
$gtm_exe/mumps -run trig
$gtm_tst/com/dbcheck.csh
