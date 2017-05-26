#!/usr/local/bin/tcsh
#
# D9I07-002689 test of $ZQUIT (anyway) compilation
#

$gtm_tst/com/dbcreate.csh mumps 1
echo "# try funky QUIT compile; setenv gtm_zquit_anyway 1"
setenv gtm_zquit_anyway 1
echo "# Compile D9I07002689.m"
$gtm_exe/mumps $gtm_tst/$tst/inref/D9I07002689.m
echo "# run D9I07002689"
$gtm_exe/mumps -run D9I07002689
\rm D9I07002689.o

echo "# verify normal (error) QUIT behavior; unsetenv gtm_zquit_anyway"
unsetenv gtm_zquit_anyway
echo "# Compile D9I07002689.m"
$gtm_exe/mumps $gtm_tst/$tst/inref/D9I07002689.m
echo "# run D9I07002689"
$gtm_exe/mumps -run D9I07002689
echo "# End of test"
$gtm_tst/com/dbcheck.csh
