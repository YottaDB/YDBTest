#!/usr/local/bin/tcsh -f
# Test that $ZTRIGGER works irrespective of the state of global variables gv_last_subsc_null and gv_some_subsc_null.

$gtm_tst/com/dbcreate.csh mumps 1

# By default NO NULL SUBSCRIPTS. Do some tests
$gtm_exe/mumps -run %XCMD "do init^ztrignullsubs"
$gtm_exe/mumps -run %XCMD "do test1^ztrignullsubs"
$gtm_exe/mumps -run %XCMD "do test2^ztrignullsubs"

# Allow NULL SUBSCRIPTS. Do some more tests
$DSE change -file -null=ALWAYS

#
$gtm_exe/mumps -run %XCMD "do test3^ztrignullsubs"
$gtm_exe/mumps -run %XCMD "do test4^ztrignullsubs"

$gtm_tst/com/dbcheck.csh
