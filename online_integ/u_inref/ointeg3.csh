#!/usr/local/bin/tcsh -f
# This subtest verifies that mupip online integ reports incorrectly marked free and doubly allocated
# block errors. 

#Go with pro image since the intentionally induced errors cause cores in dbg
source $gtm_tst/com/switch_gtm_version.csh $tst_ver "pro"

$gtm_tst/com/dbcreate.csh mumps 1 

# put a global in a block
$GTM << EOF
set ^a=3
h
EOF

# mark it free
set log1 = "log1.out"
$DSE maps -bl=3 -free >&! $log1

# should see incorrectly marked free error
$gtm_tst/com/dbcheck.csh

# "reuse" the busy block
$GTM << EOF
set ^z=5
h
EOF

# should now see doubly allocated error
$gtm_tst/com/dbcheck.csh
