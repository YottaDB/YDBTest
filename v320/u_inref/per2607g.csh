$! journal value pointer system
$ delete mumps.gld.*,mumps.dat.*,mumps.jnl.*,mumps.mjf.*
$ gde
change/region $default/key=255/rec=500/journal=(before,file=mumps.jnl)
change/segment $default/block=512
$ mupip create
$ mupip set/file mumps.dat/journal=(on,before)
$ gtm
do ^per2607g
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD transaction from per2607g"
$ endif
$ mupip journal/extract/forward mumps.jnl
$! exit
$ search/wind=0 mumps.mjf "foo"/exact
$ if $severity .ne. 1
$  then
$   write sys$output "incorrect journal from per2607g"
$ endif
$ exit
