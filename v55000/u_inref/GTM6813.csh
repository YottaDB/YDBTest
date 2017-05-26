#!/usr/local/bin/tcsh -f

####################################################################################
# This is the main script of v55000/GTM6813 test. It tests the functionality of DO #
# and $$ calls in a number of variations. A particular emphasis of this test is to #
# verify that omitting parentheses on DO calls with no actuallist works according  #
# to the newly introduced design.                                                  #
####################################################################################

####################################################################################
# Testing of various internal, external, DO, $$, and indirect invocations          #
####################################################################################
echo 'Testing various types of invocations using DO and \$\$...'

# this should generate several error messages
$gtm_dist/mumps -run docalls

echo ''

$echoline

####################################################################################
# Testing of DO invocations of routines with fall-thru/non-fall-thru header labels #
####################################################################################
echo 'Testing whether the top label in the invoked routine forwards the parameters...'

# all cases should generate error messages
$gtm_dist/mumps -run dofallthrus

echo ''

$echoline

####################################################################################
# Testing of various label invocations with undefined arguments and/or parameters  #
####################################################################################
echo 'Testing of passing undefined arguments and reading undefined parameters...'

# all cases should generate error messages
$gtm_dist/mumps -run doundefs

echo ''

$echoline

####################################################################################
# Testing of gtm_zquit_anyway-controlled behavior with DO and $$ calls as well as  #
# quit argument evaluation                                                         #
####################################################################################
echo 'Testing gtm_zquit_anyway environment variable and quit argument evaluation...'

echo ''

# first, make sure gtm_zquit_anyway and gtm_noundef are disabled; expect errors
unsetenv gtm_zquit_anyway
unsetenv gtm_noundef
$gtm_dist/mumps -run doquit

echo ''

# then enable gtm_noundef; expect errors
unsetenv gtm_zquit_anyway
setenv gtm_noundef 1
$gtm_dist/mumps -run doquit

echo ''

# enable gtm_zquit_anyway, but disable gtm_noundef; expect errors
setenv gtm_zquit_anyway 1
unsetenv gtm_noundef
$gtm_dist/mumps -run doquit

echo ''

# enable both gtm_zquit_anyway and gtm_noundef; expect no errors
setenv gtm_zquit_anyway 1
setenv gtm_noundef 1
$gtm_dist/mumps -run doquit

echo ''

$echoline

####################################################################################
# Testing of argument passing correctness when interrupted in push_parm            #
####################################################################################
echo 'Testing argument passing while issuing interrupts...'

echo ''

# define env var that contains SIGUSR1 value on all platforms
if (($HOSTOS == "OSF1") || ($HOSTOS == "AIX")) then
	setenv sigusrval 30
else if (($HOSTOS == "SunOS") || ($HOSTOS == "HP-UX") || ($HOSTOS == "OS/390")) then
	setenv sigusrval 16
else if ($HOSTOS == "Linux") then
	setenv sigusrval 10
endif

$gtm_tst/com/dbcreate.csh .

# there should be no FAIL messages
$gtm_dist/mumps -run dointerrupts

$gtm_tst/com/dbcheck.csh
