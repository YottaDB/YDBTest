#! test recover/backward against a newly created db
$gtm_tst/com/dbcreate.csh . 255 500 512 800
#! smw 97/3/5 done by dbcreate $MUPIP create
$MUPIP set -file -journal=enable,on,before,file=mumps.jnl1 mumps.dat
$GTM <<\xyz
for i=1:1:2000 set ^a(i_$j(i,20))=$j(i,20)
h
xyz
$gtm_tst/com/dbcheck.csh
$MUPIP set -file -journal=off mumps.dat
$MUPIP set -file -journal=enable,on,before,file=mumps.jnl2 mumps.dat
$GTM <<\xyz
for i=2001:1:4000 set ^a(i_$j(i,20))=$j(i,20)
h
xyz
$gtm_tst/com/dbcheck.csh
$MUPIP extract -format=go mumps_i.go
\rm -f mumps.dat
$MUPIP create
$MUPIP journal -recover -forward mumps.jnl1,mumps.jnl2
$gtm_tst/com/dbcheck.csh
$MUPIP extract -format=go mumps_f.go
\rm -f mumps.dat
$MUPIP create
$MUPIP journal -recover -backward mumps.jnl2
$gtm_tst/com/dbcheck.csh
$MUPIP extract -format=go mumps_b.go
$ exit
