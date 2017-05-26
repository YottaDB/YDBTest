#! /usr/local/bin/tcsh -f
#
# test quit if for xecute
$gtm_tst/com/dbcreate.csh .
$GTM << fin
write "do ^misc",! do ^misc
halt
fin
$gtm_tst/com/dbcheck.csh
