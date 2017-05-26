! Test of $c(0) and $c(1) at end of string subscripts (to make sure they dont get confused as ++)
add -name a("a"_$c(0))             -region=areg
add -name b("a"_$c(0)_$c(0))       -region=breg
add -name c("a"_$c(1))             -region=creg
add -name d("a"_$c(1)_$c(1))       -region=dreg
add -name e("a"_$c(0)_$c(1))       -region=ereg
add -name f("a"_$c(1)_$c(0))       -region=freg
add -name g("a"_$c(1)_$c(0)_$c(1)) -region=greg
add -name h("a"_$c(0)_$c(1)_$c(0)) -region=hreg
add -name h("abcdefghijklmnop"_$c(0)_$c(1)_$c(0)) -region=hreg
add -name h("abcdefghijklmnop"_$c(0)_$c(1)_$c(0)_"efghijklmnopqrstuvwxyz") -region=hreg
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region CREG -dyn=CREG -stdnullcoll
add -segment CREG -file=CREG.dat
add -region DREG -dyn=DREG -stdnullcoll
add -segment DREG -file=DREG.dat
add -region EREG -dyn=EREG -stdnullcoll
add -segment EREG -file=EREG.dat
add -region FREG -dyn=FREG -stdnullcoll
add -segment FREG -file=FREG.dat
add -region GREG -dyn=GREG -stdnullcoll
add -segment GREG -file=GREG.dat
add -region HREG -dyn=HREG -stdnullcoll
add -segment HREG -file=HREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
show -map -reg=AREG
show -map -reg=HREG
show -map -reg=DEFAULT

