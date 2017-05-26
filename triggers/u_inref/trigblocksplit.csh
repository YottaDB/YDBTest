#!/usr/local/bin/tcsh -f

# generate the testspecific GDE file
$gtm_exe/mumps -run gde^trigblocksplit
setenv test_specific_gde `pwd`/trigblocksplit.gde

$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run test1^trigblocksplit
$gtm_exe/mumps -run test2^trigblocksplit
$gtm_exe/mumps -run test3^trigblocksplit
$echoline
$gtm_tst/com/dbcheck.csh -extract
mkdir -p bak
mv mumps.* bak

$echoline
$gtm_tst/com/dbcreate.csh mumps 1
$echoline
echo "Repeat, but cause restart by updating global"
$gtm_exe/mumps -run %XCMD 'set ^conflict=1'
$gtm_exe/mumps -run test1^trigblocksplit
$gtm_exe/mumps -run test2^trigblocksplit
$gtm_exe/mumps -run test3^trigblocksplit
$echoline
$gtm_tst/com/dbcheck.csh -extract
