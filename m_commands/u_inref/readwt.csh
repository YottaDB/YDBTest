#! /usr/local/bin/tcsh -f
#
# test read/write/zwrite/set
$gtm_tst/com/dbcreate.csh . 1 255 1000
cp -f $gtm_tst/$tst/inref/forread.txt .
$GTM << fin
write "do ^readwrit",! do ^readwrit
halt
fin
$gtm_tst/com/dbcheck.csh
