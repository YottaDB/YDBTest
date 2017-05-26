#! /usr/local/bin/tcsh -f
#
#
set GTM="$gtm_exe/mumps -direct"
source $gtm_tst/$tst/u_inref/string.csh
$GTM <<string
Write "Do ^stringtst",!  Do ^stringtst
Halt
string
#
#
rm libxstring"$gt_ld_shl_suffix"
source $gtm_tst/$tst/u_inref/string.csh
$GTM <<mathbad
Write "Do ^stringtst",!  Do ^stringtst
Write "Do ^length",!  Do ^length
Write "Do ^stringbad",!  Do ^stringbad
Halt
mathbad
unsetenv GTMXC
#
