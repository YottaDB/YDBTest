#!/usr/local/bin/tcsh -f
#
########################################
# v44002 tests contain tests for $ZTEXIT ISV [C9D03-002246] and miscellaneous TR fixes
########################################

echo 'v44002 tests START....'

# disable implicit mprof testing to avoid interference with explicit MPROF testing
unsetenv gtm_trace_gbl_name

# define env var that contains SIGUSR1 value on all platforms (needed by the $ZTEXIT subtests)
if (($HOSTOS == "OSF1") || ($HOSTOS == "AIX")) then
    setenv sigusrval 30
else if (($HOSTOS == "SunOS") || ($HOSTOS == "HP-UX") || ($HOSTOS == "OS/390")) then
    setenv sigusrval 16
else if ($HOSTOS == "Linux") then
    setenv sigusrval 10
endif
#
set ztexit_subtest_list = "errorint manyints multintr nesttp nointrpt refniosv smpltp snglintp tpwint"
setenv subtest_list "${ztexit_subtest_list} D9D04002314"

$gtm_tst/com/submit_subtest.csh
echo 'v44002 tests DONE....'
