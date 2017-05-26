#! /usr/local/bin/tcsh -f
#
echo "TSTART test starts for longnames...."
$gtm_tst/com/dbcreate.csh mumps
$GTM << \eof
view "NOUNDEF"
set passval="errorOFF"
do ^chktstrt(passval)
view "UNDEF"
set passval="errorON"
do ^chktstrt(passval)
h
\eof
$gtm_tst/com/dbcheck.csh
echo "TSTART test for longnames ends"
