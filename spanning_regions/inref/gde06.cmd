! Test scenario where resulting map has an interesting pattern.
add -name X           -region=areg
add -name X(0:2)      -region=breg
add -name X(1,2)      -region=creg
add -name X(1,2,3:)   -region=breg
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
