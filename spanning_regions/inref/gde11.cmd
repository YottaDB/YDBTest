! Test of simple map, but complex namespaces involving ranges and overriding points
add -name X         -region=BREG
add -name X(1)      -region=BREG
add -name X(1,2)    -region=BREG
add -name X(1,2,3:) -region=AREG
add -name X(1,2:)   -region=AREG
add -name X(1:2)    -region=AREG
add -name X(2:)     -region=CREG
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
