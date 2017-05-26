#!/usr/local/bin/tcsh -f

# Change in KILL logic to support both M-Standard Kill as well as non-M Standard Kill. The default behavior will be 
# non-M standard Kill. gtm_stdxkill/GTM_STDXKILL on UNIX/VMS (respectively) if specified as "1" or "TRUE" or "YES" 
# (case insensitive) will indicate whether the default behavior has to be overridden
#

echo "C9J11003211 test starts..."

$echoline
echo "Test 1: gtm_stdxkill not set in the evironment. Expect PASS"
unsetenv gtm_stdxkill
$gtm_exe/mumps -r C9J11003211

$echoline
echo "Test 2: gtm_stdxkill set to 1 (override default Kill behavior) in the environment. Expect PASS"
setenv gtm_stdxkill 1
$gtm_exe/mumps -r C9J11003211

$echoline
echo "Test 3: gtm_stdxkill set to a bad value - 'BAD'. Expect Invalid Setting via Error trap"
setenv gtm_stdxkill "BAD"
$gtm_exe/mumps -r C9J11003211

echo "C9J11003211 test ends.."
