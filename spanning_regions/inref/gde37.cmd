! A simple test of POINT-type (no ranges) subscripted names
add -name a -region=AREG
add -name b -region=BREG
add -name c -region=CREG
add -name a(1) -reg=AREG
add -name a(2,"efgh") -reg=BREG
add -name a(3,5,7,8,"zzz",10) -reg=CREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region CREG -dyn=CREG -stdnullcoll
add -segment CREG -file=CREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
