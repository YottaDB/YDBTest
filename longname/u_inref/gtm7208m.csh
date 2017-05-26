#!/usr/local/bin/tcsh -f
$switch_chset M >&! switch_chset.out
$gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
lock +limitlock(5,100,"LLL","YYY","pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|12345")
lock +limitlockpassby1(5,100,"LLL","YYY","pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|123456")
EOF
$gtm_tst/com/dbcheck.csh mumps
