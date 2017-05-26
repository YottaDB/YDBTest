#!/usr/local/bin/tcsh -f
#
# C9I11-003055 GT.M fails with SIG-11 if multiple regions map to same database file
#

# Enable malloc checking to make sure freed memory is never (re)used
setenv gtmdbglvl 497

$gtm_tst/com/dbcreate.csh mumps
cp mumps.gld mumpsec0.gld

$GTM <<GTM_EOF
	do ^c003055
GTM_EOF

$gtm_tst/com/dbcheck.csh
