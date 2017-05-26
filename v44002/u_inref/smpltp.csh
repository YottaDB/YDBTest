source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
w !,"Do ^tp",! d ^tp
h
EOF

$gtm_tst/com/dbcheck.csh -extract
