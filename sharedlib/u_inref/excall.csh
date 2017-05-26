#! /usr/local/bin/tcsh -f
#
#
source $gtm_tst/$tst/u_inref/math.csh
$GTM <<math
Write "Do ^mathtst",!  Do ^mathtst
Halt
math
#
#
# Test mathbad - Improper callin format
rm libxmath"$gt_ld_shl_suffix"
source $gtm_tst/$tst/u_inref/math.csh
$GTM <<mathbad
Write "Do ^mathtst",!  Do ^mathtst
Write "Do ^avg",!  Do ^avg
Write "Do ^mathbad",!  Do ^mathbad
Halt
mathbad
unsetenv GTMXC
#
