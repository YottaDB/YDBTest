! Test some more subscripted name scenarios
add -name X(2,4)      -region=areg
add -name X(2,4,5:)   -region=breg
add -name X(2,4:5)    -region=breg
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map

