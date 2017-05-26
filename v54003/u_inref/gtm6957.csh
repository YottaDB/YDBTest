#!/usr/local/bin/tcsh -f
# gtm6957 - Check $ZTRNLNM() keyword handling
echo Starting gtm6957
unsetenv bar
setenv foo bar
setenv sailor
$gtm_exe/mumps -run gtm6957
unsetenv foo
unsetenv sailor
echo Ending gtm6957
