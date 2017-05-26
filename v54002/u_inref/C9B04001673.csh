#!/usr/local/bin/tcsh -f
#
# C9B04-001673 provide option to not skip $I(), $$ or $& in boolean expressions because they have side-effects
#
$gtm_tst/com/dbcreate.csh mumps
unsetenv gtm_side_effects		# might otherwise subvert the intention of this test
$gtm_dist/mumps -run C9B04001673
echo " "
setenv save_boolean 0
if ($?gtm_boolean) then
  setenv save_boolean $gtm_boolean
endif
setenv gtm_boolean 2
$gtm_dist/mumps -run C9B04001673d
setenv gtm_boolean 1
$gtm_dist/mumps -run C9B04001673d
unsetenv gtm_boolean
$gtm_dist/mumps -run C9B04001673d
echo " "
setenv gtm_boolean $save_boolean
unsetenv save_boolean
$gtm_tst/com/dbcheck.csh
