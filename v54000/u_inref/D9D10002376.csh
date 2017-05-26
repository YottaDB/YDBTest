#!/usr/local/bin/tcsh -f
#
# D9D10-002376 Verify LVNULLSUBS is comprehensively handled
#
setenv gtm_lvnullsubs 0

$gtm_dist/mumps -run d002376

setenv gtm_lvnullsubs 1
$gtm_dist/mumps -run d002376

setenv gtm_lvnullsubs 2
$gtm_dist/mumps -run d002376

unsetenv gtm_lvnullsubs

