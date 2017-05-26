#!/usr/local/bin/tcsh -f
# The test calls two scripts as
# i.actuallists.csh to check actualvsformal list parameters in M-Routines.
# ii.callbyreference.csh to check callbyreference mechanism in M-Routines.
#
# dbcreate is used to create a database to check globals in parameter passing.
$gtm_tst/com/dbcreate.csh mumps
#
echo "###### Begin Actual Formal Parameter List check ######"
$gtm_tst/$tst/u_inref/actuallists.csh
#
$gtm_tst/com/dbcheck.csh
#
echo "###### Begin call by reference parameters check ######"
$gtm_tst/$tst/u_inref/callreference.csh
#
$gtm_tst/com/dbcheck.csh
