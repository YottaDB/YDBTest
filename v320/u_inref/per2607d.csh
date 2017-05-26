$! test more complex before imaged journaled transaction and both recoveries
$ delete mumps.gld.*,mumps.dat.*,mumps.jnl.*
$ gde
change/region $default/key=255/rec=500/journal=(before,file=mumps.jnl)
change/segment $default/block=512
$ mupip create
$ mupip set/file mumps.dat/journal=(on,before)
$! exit
$ gtm
f i=1,2,3 s ^a(i_$j(i,240))=$j(i,240)
f i=1,2,3 s ^b(i_$j(i,240))=$j(i,240)
tstart ():serial
k ^a
f i=2 k ^b(i_$j(i,240))
tcommit
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD transaction from per2607d"
$ endif
$ mupip journal/recover/backward mumps.jnl
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD backward recovery from per2607d"
$ endif
$ delete mumps.dat.
$ mupip create
$ mupip journal/recover/forward mumps.jnl
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD forward recovery from per2607d"
$ endif
$ exit
