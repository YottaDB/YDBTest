#! /usr/local/bin/tcsh -f
# per2607a.csh
$gtm_tst/com/dbcreate.csh . 1 255 500 
$GTM <<abc
tstart ():serial
s ^a="a"
s ^b="b"
tcommit
h
abc
$gtm_tst/com/dbcheck.csh -extract 
$MUPIP set -file -journal=off mumps.dat
$MUPIP journal -recover -backward mumps.jnl
$gtm_tst/com/dbcheck.csh 
\rm -f mumps.dat
\rm -f mumps.gld
$gtm_tst/com/dbcreate.csh .  1 255 500
$MUPIP journal -recover -forward mumps.jnl
$gtm_tst/com/dbcheck.csh 
