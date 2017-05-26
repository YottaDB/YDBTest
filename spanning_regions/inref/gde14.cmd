! Test mixing unsubscripted and subscripted namespaces
add -name XX*      -region=CREG
add -name XX       -region=AREG
add -name XX(1)    -region=AREG
add -name XX(1,2:) -region=BREG
add -name XX(1:)   -region=BREG
add -name XY*      -region=CREG
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
