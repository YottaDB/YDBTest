$! test more complex before imaged journaled transaction and both recoveries
$ delete mumps.gld.*,mumps.dat.*,mumps.jnl.*
$ gde
change/region $default/key=255/rec=500/journal=(before,file=mumps.jnl)
change/segment $default/block=512
$ mupip create
$ mupip set/file mumps.dat/journal=(on,before)
$! exit
$ gtm
tstart ():serial
f i=1,2,3 s ^a(i_$j(i,240))=$j(i,240)
f i=3,2,1 s ^b(i_$j(i,240))=$j(i,240)
f i=1,3,2 s ^c(i_$j(i,240))=$j(i,240)
tcommit
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD transaction from per2607b"
$ endif
$ mupip journal/recover/backward mumps.jnl
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD backward recovery from per2607b"
$ endif
$ delete mumps.dat.
$ mupip create
$ mupip journal/recover/forward mumps.jnl
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD forward recovery from per2607b"
$ endif
$ exit
