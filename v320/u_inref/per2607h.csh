$! test set of a null value
$ delete mumps.gld.*,mumps.dat.*,mumps.jnl.*
$ gde
change/region $default/key=255/rec=500/journal=(before,file=mumps.jnl)
$ mupip create
$ mupip set/file mumps.dat/journal=(on,before)
$! exit
$ gtm
d ^PER2607h
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD transaction from per2607h"
$ endif
$ mupip journal/recover/backward mumps.jnl
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD backward recovery from per2607h"
$ endif
$ delete mumps.dat.
$ mupip create
$ mupip journal/recover/forward mumps.jnl
$ define/user sys$output nl:
$ mupip integ/full mumps.dat
$ if $severity .ne. 1
$  then
$   write sys$output "BAD forward recovery from per2607h"
$ endif
$ exit
