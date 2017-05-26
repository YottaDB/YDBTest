#!/usr/local/bin/tcsh -f

#
# Run test for S9K07-002782 - for loop does not iterate properly on 32 bit n
# on-shared binary architectures. Known to fail are Linux x86 (V5.2-000 thru V5.4-001)
# and Solaris (V5.2-000 thru V5.3-001A)
#
$gtm_tst/com/dbcreate.csh mumps

$gtm_dist/mumps -run D9K07002782
$gtm_tst/com/dbcheck.csh
