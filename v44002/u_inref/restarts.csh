source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
w !,"Do singlec^restarts",! d singlec^restarts
h
EOF
#
$GTM<<EOF
w !,"Do singler^restarts",! d singler^restarts
h
EOF
#
$GTM<<EOF
w !,"Do nestedc^restarts",! d nestedc^restarts
h
EOF
#
$gtm_tst/com/dbcheck.csh -extract