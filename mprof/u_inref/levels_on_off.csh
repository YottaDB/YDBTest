#!/usr/local/bin/tcsh -f
# Test various combinations of (levels of) ON  and OFF
# C9B08-001730

$gtm_exe/mumps -run lev1
$gtm_exe/mumps -run trace

$gtm_exe/mumps -run lev2
$gtm_exe/mumps -run trace

$gtm_exe/mumps -run lev3
$gtm_exe/mumps -run trace

$gtm_exe/mumps -run lev4
$gtm_exe/mumps -run trace

